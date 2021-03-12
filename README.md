# Redmine Slack Integration Plugin

For Redmine 3.x.x.

### Plugin installation

1.  Copy the plugin directory into the $REDMINE_ROOT/plugins directory. Please
    note that plugin's folder name should be "redmine_slack_integration".

2.  Install 'httpclient'

    e.g. bundle install

3.  Do migration task.

    e.g. RAILS_ENV=production rake redmine:plugins:migrate

4.  (Re)Start Redmine.

### Uninstall

Try this:

*  RAILS_ENV=production rake db:migrate_plugins NAME=redmine_slack_integration VERSION=0

### Settings

#### Set Slack API URL

1.  Login redmine used redmine admin account.

2.  Open the top menu "Administration" -> "Plugins" -> "Redmine Slack Integration plugin" -> "Configure" page

3.  Set 'https://slack.com/api/chat.postMessage' into "Slack API URL".

4.  Apply this configure.

#### Set SLack Token and SLack Channel project

1.  Login redmine used the project admin account.

2.  Open this project "Settings" -> "Information" tag.

3.  Set your Slack APP's token into "SLack Token".

4.  Set your Slack Channel into "SLack Channel".

5.  Save this project settings.

### Disable specified project

1.  Login redmine used yourself accout.

2.  Open the project menu "Settings" page.

3.  Switch "Slack Disabled" to "Yes"

### Disable specified accout

1.  Login redmine used yourself accout.

2.  Open the top right menu "My account" page.

3.  Switch "Slack Disabled" to "Yes"

### How to use

1.  Create a new issue, and your chat room will get a message from redmine.

2.  Edit any issue, and your chat room will get a message from redmine.
