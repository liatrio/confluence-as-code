#!/usr/bin/ruby
require 'rubygems'
require 'json'

file = File.read('page.json')
json = JSON.parse(file)

require 'open3'

# Initial parse of JSON
credentials = json['credentials']
metadata = json['metadata']

# Parse 'credentials' from JSON
username = credentials['username']
password = credentials['password']

# Parse 'metadata' from JSON
space_key = metadata['space_key']
confluence = metadata['confluence']
jira_id = metadata['jira_id']
jira_host = metadata['jira_host']
page_title = metadata['page_title']
parent_id = metadata['parent_id']

# Initialize empty array for xhtml objects
html = []

# Create xhtml for jira filter gadget
def jira_filter(filter, title, max_issues, jira_host, jira_id)
	filter.gsub!("\"", "\\\"")
	f_html = "<h2>#{title}</h2><p><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"ee4dd660-2833-4a8f-aee4-bce015a6503b\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"columns\\\">key,summary,assignee,priority,status</ac:parameter><ac:parameter ac:name=\\\"maximumIssues\\\">#{max_issues}</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\"> #{filter} </ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro></p>"
end

# Create xhtml for pie chart gadget
def pie_chart(filter, jira_host, jira_id)
	filter.gsub!("\"", "\\\"")
	f_html = "<p><ac:structured-macro ac:name=\\\"jirachart\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"1cc2e1e8-894f-4268-9d1d-17afafa9f0f3\\\"><ac:parameter ac:name=\\\"border\\\">false</ac:parameter><ac:parameter ac:name=\\\"showinfor\\\">false</ac:parameter><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jql\\\">#{filter}</ac:parameter><ac:parameter ac:name=\\\"statType\\\">statuses</ac:parameter><ac:parameter ac:name=\\\"chartType\\\">pie</ac:parameter><ac:parameter ac:name=\\\"width\\\" /><ac:parameter ac:name=\\\"IsAuthenticated\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro></p>"
end

# Create xhtml for two dimensional jira filter
def two_dimensional(filter, num, jira_host, jira_id)
  filter.gsub!("\"", "\\\"")
  f_html = "<p><ac:structured-macro ac:name=\\\"jirachart\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"f8ccfac6-5052-485d-9190-1e22b63ffdd6\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"sortDirection\\\" /><ac:parameter ac:name=\\\"jql\\\">#{filter}</ac:parameter><ac:parameter ac:name=\\\"ystattype\\\">project</ac:parameter><ac:parameter ac:name=\\\"chartType\\\">twodimensional</ac:parameter><ac:parameter ac:name=\\\"width\\\" /><ac:parameter ac:name=\\\"sortBy\\\" /><ac:parameter ac:name=\\\"IsAuthenticated\\\">true</ac:parameter><ac:parameter ac:name=\\\"numberToShow\\\">#{num}</ac:parameter><ac:parameter ac:name=\\\"xstattype\\\">statuses</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro></p>"
end

# Create xhtml for custom release table
def time_progression(filter, projects, jira_host, jira_id)
	filter.gsub!("\"", "\\\"")
	to_return = ""

  to_return += "<table class=\\\"wrapped\\\"><colgroup><col style=\\\"width: 6.75106%;\\\" /><col style=\\\"width: 14.4758%;\\\" /><col style=\\\"width: 15.6443%;\\\" /><col style=\\\"width: 15.7741%;\\\" /><col style=\\\"width: 15.9688%;\\\" /><col style=\\\"width: 16.1636%;\\\" /><col style=\\\"width: 14.9951%;\\\" /></colgroup><tbody><tr><th>Application</th><th>10 Weeks Ago</th><th>8 Weeks Ago</th><th>6 Weeks Ago</th><th>4 Weeks Ago</th><th>2 Weeks Ago</th><th colspan=\\\"1\\\">Today</th></tr>"

	projects.each do |project_key,project_name|

		to_return += "<tr><td><a class=\\\"external-link\\\" href=\\\"http://#{jira_host}/projects/#{project_key}?selectedItem=com.atlassian.jira.jira-projects-plugin:release-page&amp;status=no-filter\\\" rel=\\\"nofollow\\\" style=\\\"text-align: center;\\\">#{project_name}</a></td><td><div class=\\\"content-wrapper\\\"><p><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"853b0d70-ff4f-4f52-b1ed-ba4185ec8252\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">\#{filter} AND project = \\\"#{project_name}\\\" and status was in (Open, \\\"In Progress\\\") on startOfDay(-70)   </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro> Open / <ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"df91f551-141e-4475-a3b7-07553e2bf323\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} AND project = \\\"#{project_name}\\\" and status was in (Resolved, Closed) on startOfDay(-70)   </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro> Resolved</p></div></td><td><div class=\\\"content-wrapper\\\"><p><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"fe0a7194-a630-4e90-99de-c4b8d2f849ac\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} AND project = \\\"#{project_name}\\\" and status was in (Open, \\\"In Progress\\\") on startOfDay(-56)  </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Open / </span><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"d19d6825-d80d-47a6-9316-2e657efd667a\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} AND project = \\\"#{project_name}\\\" and status was in (Resolved, Closed) on startOfDay(-56)  </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Resolved</span></p></div></td><td><div class=\\\"content-wrapper\\\"><p><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"95b17659-bc75-495c-834a-874463da1f54\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} AND project = \\\"#{project_name}\\\" and status was in (Open, \\\"In Progress\\\") on startOfDay(-42)  </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Open / </span><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"fc30506e-ef8f-4ce0-824b-687484ede2b3\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} AND project = \\\"#{project_name}\\\" and status was in (Resolved, Closed) on startOfDay(-42)  </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Resolved</span></p></div></td><td><div class=\\\"content-wrapper\\\"><p><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"2c7a6d54-de92-42d2-ae0b-07a27b05a9f0\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} AND project = \\\"#{project_name}\\\" and status was in (Open, \\\"In Progress\\\") on startOfDay(-28)  </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Open / </span><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"855c7be1-5a81-4076-af86-943ac228586c\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} AND project = \\\"#{project_name}\\\" and status was in (Resolved, Closed) on startOfDay(-28)  </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Resolved</span></p></div></td><td><div class=\\\"content-wrapper\\\"><p><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"21847488-c6a4-4a31-a125-76b2ceee7e7c\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} AND project = \\\"#{project_name}\\\" and status was in (Open, \\\"In Progress\\\") on startOfDay(-14)  </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Open / </span><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"0769f3e1-460a-461d-be06-09dcf2da4d02\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} AND project = \\\"#{project_name}\\\" and status was in (Resolved, Closed) on startOfDay(-14)  </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Resolved</span></p></div></td><td colspan=\\\"1\\\"><div class=\\\"content-wrapper\\\"><p><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"feb90ab2-cb16-4086-b819-872bb2176293\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} AND project = \\\"#{project_name}\\\" and status was in (Open, \\\"In Progress\\\") on now()  </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Open / </span><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"fd4026e3-e8a8-4882-9aa5-3a6b4220223e\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} AND project = \\\"#{project_name}\\\" and status was in (Resolved, Closed) on now()  </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Resolved</span></p></div></td></tr>"
	end

  to_return += "<tr><td>Total</td><td><div class=\\\"content-wrapper\\\"><p><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"9db6ea93-cf2b-4fc1-9878-04b407457263\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} and status was in (Open, \\\"In Progress\\\") on startOfDay(-70)    </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Open / </span><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"69a772eb-3e18-45d0-9f42-abc3468fba72\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} and status was in (Resolved, Closed) on startOfDay(-70)    </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Resolved</span></p></div></td><td><div class=\\\"content-wrapper\\\"><p><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"2c3eba73-65ec-4f39-bc3c-3e5a72c0a4f1\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter}  and status was in (Open, \\\"In Progress\\\") on startOfDay(-56)   </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Open / </span><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"bbabe746-fdcf-4da3-bb02-06db2cb8e494\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} and status was in (Resolved, Closed) on startOfDay(-56)   </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Resolved</span></p></div></td><td><div class=\\\"content-wrapper\\\"><p><span> <ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"fcfdfe79-f44d-4cc2-b3d8-1f2b2e6e6afe\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} and status was in (Open, \\\"In Progress\\\") on startOfDay(-42)    </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Open / </span><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"f3ad8a97-9f2c-4c9a-b41f-f7cdecf47306\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter}  and status was in (Resolved, Closed) on startOfDay(-42)   </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Resolved</span></span></p></div></td><td><div class=\\\"content-wrapper\\\"><p><span> <ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"83f37231-fba6-4a61-a276-b1722ba1743d\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} and status was in (Open, \\\"In Progress\\\") on startOfDay(-28)   </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Open / </span><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"a5860acb-69dc-47ac-bb32-2a7d930c0dff\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter}  and status was in (Resolved, Closed) on startOfDay(-28)   </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Resolved</span></span></p></div></td><td><div class=\\\"content-wrapper\\\"><p><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"a78a6f84-ec98-45a9-adc8-727545adfd4a\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} and status was in (Open, \\\"In Progress\\\") on startOfDay(-14)   </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Open / </span><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"d3a36086-429d-46da-b0c2-46c22a722aa1\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} and status was in (Resolved, Closed) on startOfDay(-14)   </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Resolved</span></p></div></td><td colspan=\\\"1\\\"><div class=\\\"content-wrapper\\\"><p><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"d34eea41-1b36-4a0d-a366-f665f0b20672\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} and status was in (Open, \\\"In Progress\\\") on now()   </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Open / </span><ac:structured-macro ac:name=\\\"jira\\\" ac:schema-version=\\\"1\\\" ac:macro-id=\\\"a47856e8-e709-41ce-80fa-88337586d90f\\\"><ac:parameter ac:name=\\\"server\\\">#{jira_host} JIRA</ac:parameter><ac:parameter ac:name=\\\"jqlQuery\\\">#{filter} and status was in (Resolved, Closed) on now()   </ac:parameter><ac:parameter ac:name=\\\"count\\\">true</ac:parameter><ac:parameter ac:name=\\\"serverId\\\">#{jira_id}</ac:parameter></ac:structured-macro><span> Resolved</span></p></div></td></tr></tbody></table>"
  return to_return
end

# Iterate through gadgets in JSON, create array of xhtml
json['gadgets'].each do |gadget|
	if(gadget['type'] == "jira_filter")
		html.push(jira_filter(gadget['filter'],gadget['title'],gadget['max_issues'],jira_host, jira_id))
	elsif(gadget['type'] == "pie_chart")
		html.push(pie_chart(gadget['filter'], jira_host, jira_id))
  elsif gadget['type'] == "2d-chart"
    html.push(two_dimensional(gadget['filter'],50,jira_host,jira_id))
  elsif gadget['type'] == "time_progression"
		html.push(time_progression(gadget['filter'], gadget['projects'], jira_host, jira_id))
	else
		puts "Invalid Gadget Type " + gadget['type']
	end

end


code = "\""

# Concatonate array values into single string
html.each do |block|
	code += block
end

 code += "\""


# Execute curl to create page
output = "Page Created!"
stdout, stderr, status = Open3.capture3("curl -u #{username}:#{password} -X POST -H 'Content-Type: application/json' -d'{\"type\":\"page\",\"title\":\"#{page_title}\",\"ancestors\":[{\"id\":#{parent_id}}],\"space\":{\"key\":\"#{space_key}\"},\"body\":{\"storage\":{\"value\":#{code},\"representation\":\"storage\"}}}' #{confluence} | python -mjson.tool | grep message ")

# Output success or error message
# puts stderr
if stdout == "        \"message\": \"\",\n"
	puts "Success!"
else
	puts stdout
  puts stderr
end
