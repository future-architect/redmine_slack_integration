# Redmine Slack Integration Plugin

For Redmine 4.x.x.

### Plugin installation

1.  Copy the plugin directory into the `$REDMINE_ROOT/plugins` directory. Please
    note that plugin's folder name should be `redmine_slack_integration`.
    
```sh
git clone git@github.com:future-architect/redmine_slack_integration.git redmine_slack_integration
```

2.  Install gem dependencies.

```sh
bundle install
```

3.  Run migration task.

```sh
RAILS_ENV=production rake redmine:plugins:migrate
```

4.  (Re)Start Redmine.

### Settings

#### How to set Slack OAuth & Permissions

1.  Open [Your Apps - Slack API](https://api.slack.com/apps/new) from the following URL and create an app via "From scratch".

2.  Open "Add features and functionality" -> "Permissions" -> "Scopes" and add the following oauth scopes to "Slack Bot Token Scopes".

    *  `chat:write`

    *  `chat:write.customize`

    *  `chat:write.public`

    *  `users:read`

    *  `users:read.email`

#### Set Slack API URL

1.  Log in to redmine with a redmine admin account.

2.  Go to "Administration" in the top menu -> "Plugins" -> "Redmine Slack Integration plugin" -> "Configuration" page.

3.  Set `https://slack.com/api` into "Slack API URL" field.

4.  Save this configuration.

#### Set Slack Token and Slack Channel project

1.  Log in to redmine with a project admin account.

2.  Open this project's "Settings" -> "Project" tab.

3.  Set your Slack App's "Bot User OAuth Token" ( starting with `xoxb-` ) to "Slack Token" field.

4.  Set your Slack channel name ( starting with `#` ) to "Slack Channel" field.

5.  Switch "Slack Disabled" to "No".

6.  Save this project settings.

#### Enable notification of your account

1.  Log in to redmine with your account.

2.  Open "My account" on the right of top menu.

3.  Switch "Slack Disabled" to "No".

### Disable specified project

1.  Log in to redmine with a project admin account.

2.  Open the project's "Settings" -> "Project" tab.

3.  Switch "Slack Disabled" to "Yes".

### Disable specified account

1.  Log in to redmine with your account.

2.  Open "My account" on the right of top menu.

3.  Switch "Slack Disabled" to "Yes".

### When get notification?

1.  Create a new issue, and your chat room will get a message from redmine.

2.  Edit any issue, and your chat room will get a message from redmine.

### Uninstall

```sh
RAILS_ENV=production rake db:migrate_plugins NAME=redmine_slack_integration VERSION=0
```
