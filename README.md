# Confluence as Code
## Create confluence gadgets with JSON!


#### Purpose:

At [liatrio](liatr.io), many of our customers use the [atlassian](https://www.atlassian.com) suite of productivity tools. In order to stay current, we use [Jira](https://www.atlassian.com/software/jira) and [Confluence](https://www.atlassian.com/software/confluence) ourselves to track work internally. One issue we faced was the amount of _time_ it took to create confluence pages with multiple gadgets that gave a high level view of work for a given project. These pages were great when finished, and using JIRA filters allowed us to know the progress made at a glance, however the time it took to set each one up took time away from projects we wanted to work on. So we decided to automate it!


#### Requirements:

  - Confluence and Jira applications running, both connected with [application links](https://confluence.atlassian.com/doc/use-jira-applications-and-confluence-together-427623543.html)
  - Desired Jira filters created and saved in Jira
  - Credentials with permission to create confluence page in desired location


#### How it works:

Our tool parses a provided JSON, creates xhtml gadgets in the storage format used by confluence, and then sends a POST request to the specified confluence server. The format is loosely based on the [confluence rest api examples](https://developer.atlassian.com/confdev/confluence-server-rest-api/confluence-rest-api-examples) provided by atlassian.


#### Usage:

To start creating confluence pages, you simply need to write a JSON file (page.json) containing the required information and credentials, and run the script with `ruby confluence.rb`

##### Note: jira filters can be entered as `literal filters` or as `saved filters:`

- `Literal filters` are entered directly, i.e.:
```
"project = MMOB ORDER BY Rank ASC"
```

- `Saved filters` are entered by specifying the name in escaped quotes i.e.
```
"filter = \"Release R3.0 Full Scope\"
```  

The format of the JSON is as follows:
```
{
  "metadata" : {
    "confluence" : "<confluence hostname>/rest/api/content",
    "jira_id" : "<jira instance id>",
    "jira_host" : "<jira hostname>",
    "page_title" : "<page_title>",
    "parent_id" : "<parent_page>",
    "space_key" : "<key>"
  },
  "credentials" : {
    "username" : "<username>",
    "password" : "<password>"
  },
  "gadgets" : [
    {
        "type" : "jira_filter",
        "filter" : "<jira filter>",
        "title" : "<desired title>",
        "max_issues" : "<max number of issue>"
    },
    {
        "type" : "pie_chart",
        "filter" : "<Jira filter>"
    },
    {
      "type" : "2d-chart",
      "filter" : "<jira filter>",
      "size" : "<max number of issues>"
    },
    {
      "type" : "time_progression",
      "filter" : "<JIRA filter>",
      "projects" : {
          "<projectKey>" : "<projectName",
          "<projectKey>" : "<projectName",
          "<projectKey>" : "<projectName"
        }
    }
  ]
}
```
The `metadata` determines where the page will be located
The `credentials` determines the user login/password used when creating the page
The  `gadgets` contains all of the gadgets that will be created
- Currently the supported gadget types are "jira_filter", "pie_chart", "2d-chart", as well as our own custom gadget, "time_progression"

#### Example:
```
{
  "metadata" : {
    "confluence" : "<redacted>/rest/api/content",
    "jira_id" : "<redacted>",
    "jira_host" : "<redacted>",
    "page_title" : "Gadgets as code",
    "parent_id" : "1337",
    "space_key" : "TEST"
  },
  "credentials" : {
    "username" : "<redacted>",
    "password" : "<redacted>"
  },
  "gadgets" : [
    {
      "type" : "jira_filter",
      "filter" : "\"Release R3.0 Full Scope\"",
      "max_issues" : "5"
    },
    {
      "type" : "pie_chart",
      "filter" : "project = \"Producer Web\" AND fixVersion = 4.4.1"
    },
    {
      "type" : "2d-chart",
      "filter" : "project = MMOB ORDER BY Rank ASC"
    },
    {
      "type" : "time_progression",
      "filter" : "Release R3.0 Full Scope",
      "projects" : {
        "PWEB" : "Producer Web"
      }
    }
  ]
}
```
