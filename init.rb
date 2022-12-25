require File.dirname(__FILE__) + '/lib/redmine_slack_integration/hooks'
require File.dirname(__FILE__) + '/lib/redmine_slack_integration/issue_relations_controller_patch'

################################################################################
## Register Plugin
################################################################################
Redmine::Plugin.register :redmine_slack_integration do
  name 'Redmine Slack Integration plugin'
  author 'Future Corporation'
  description 'This is a plugin for Redmine Slack Integration'
  version '0.2.4'
  url 'https://www.future.co.jp/'
  author_url 'https://www.future.co.jp/'

  settings :default => {:slack_api_url => 'https://slack.com/api/chat.postMessage'}, :partial => 'settings/slack_integration_settings'
end
