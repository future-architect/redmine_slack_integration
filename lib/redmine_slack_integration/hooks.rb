require 'httpclient'

module RedmineSlackIntegration
  class Hooks < Redmine::Hook::ViewListener
    CHARLIMIT = 1000
    include ApplicationHelper
    include CustomFieldsHelper
    include IssuesHelper

################################################################################
## Hook for issues_new_after_save
################################################################################
    def controller_issues_new_after_save(context={})
      ## check user
      return if is_user_disabled(User.current)

      ## Get issue
      issue = context[:issue]

      ## Is project disabled
      return if is_project_disabled(issue.project)

      ## Is private issue
      return if issue.is_private

      ## Get issue URL
      issue_url = get_object_url(issue)

      ## Get Slack info
      slack_info = get_slack_info(issue.project)
      return if slack_info.nil?

      ## Slack chat data
      data = {}

      ## Add slack channel
      data['channel'] = slack_info['channel']

      ## Add issue updated_on
      data['text'] = "*#{l(:field_updated_on)}:#{issue.updated_on}*"

      ## Add issue subject
      subject = issue.subject.gsub(/[　|\s|]+$/, "")
      data['text'] = data['text'] + "\n*#{l(:field_subject)}:<#{issue_url}|[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] #{subject}>*"

      ## Add issue URL
      data['text'] = data['text'] + "\n*URL:* #{issue_url}\n"

      ## Add issue author
      data['text'] = data['text'] + "\n```\n" + l(:text_issue_added, :id => "##{issue.id}", :author => issue.author)

      ## Add issue attributes
      data['text'] = data['text'] + "\n#{''.ljust(37, '-')}\n" + render_email_issue_attributes(issue, User.current)

      ## Add issue descripption
      unless issue.description.blank?
        description = issue.description.truncate(CHARLIMIT, omission: "\n...")
        data['text'] = data['text'] + "\n#{''.ljust(37, '-')}\n[#{l(:field_description)}]\n#{description}"
      end

      ## Add issue attachments
      if issue.attachments.any?
        data['text'] = data['text'] + "\n\n#{l(:label_attachment_plural).ljust(37, '-')}"
        issue.attachments.each do |attachment|
           data['text'] = data['text'] + "\n#{attachment.filename} #{number_to_human_size(attachment.filesize)}"
        end
      end

      ## Add ```
      data['text'] = data['text'] + "\n```"

      ## Add mention
      data['text'] = data['text'] + "\n"

      ## Add assigned to
      sui_assigned_to = get_slack_user_id(issue.assigned_to_id, slack_info['token'])
      data['text'] = data['text'] + "<@#{sui_assigned_to}>" unless sui_assigned_to.blank?

      ## Add watcher
      issue.watcher_user_ids.each do |wid|
        next if issue.assigned_to_id == wid
        sui_watcher = get_slack_user_id(wid, slack_info['token'])
        data['text'] = data['text'] + " <@#{sui_watcher}>" unless sui_watcher.blank?
      end

      ## Post message data
      thread_ts = post_maessage(nil, slack_info['token'], data)
      set_slack_thread_ts(issue, thread_ts)
    end

################################################################################
## Hook for controller_issues_edit_after_save
################################################################################
    def controller_issues_edit_after_save(context={})
      ## check user
      return if is_user_disabled(User.current)

      ## Get issue and journal
      issue = context[:issue]
      journal = context[:journal]

      ## Is project disabled
      return if is_project_disabled(issue.project)

      ## Is private issue
      return if issue.is_private
      return if journal.private_notes

      ## Get issue URL
      issue_url = get_object_url(issue)

      ## Get Slack info
      slack_info = get_slack_info(issue.project)
      return if slack_info.nil?

      ## Slack chat data
      data = {}

      ## Add slack channel
      data['channel'] = slack_info['channel']

      ## Add slack thread_ts
      data['thread_ts'] = get_slack_thread_ts(issue)

      ## Add reply_broadcast
      data['reply_broadcast'] = true

      ## Add issue updated_on
      data['text'] = "*#{l(:field_updated_on)}:#{issue.updated_on}*"

      ## Add issue subject
      subject = issue.subject.gsub(/[　|\s|]+$/, "")
      data['text'] = data['text'] + "\n*#{l(:field_subject)}:<#{issue_url}|[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] #{subject}>*"

      ## Add issue URL
      data['text'] = data['text'] + "\n*URL:* #{issue_url}\n"

      ## Add issue author
      data['text'] = data['text'] + "\n```\n" + l(:text_issue_updated, :id => "##{issue.id}", :author => journal.user)

      ## Add issue details
      details = details_to_strings(journal.visible_details, true).join("\n")
      unless details.blank?
        data['text'] = data['text'] + "\n#{''.ljust(37, '-')}\n#{details}"
      end

      ## Add issue description
      journal.visible_details.each do |detail|
        if detail.prop_key == 'description'
          description = detail.value.truncate(CHARLIMIT, omission: "\n...")
          data['text'] = data['text'] + "\n#{''.ljust(37, '-')}\n[#{l(:field_description)}]\n#{description}"
          break
        end
      end

      ## Add issue notes
      unless issue.notes.blank?
        notes = issue.notes.truncate(CHARLIMIT, omission: "\n...")
        data['text'] = data['text'] + "\n#{''.ljust(37, '-')}\n[#{l(:field_notes)}]\n#{notes}"
      end

      ## Add ```
      data['text'] = data['text'] + "\n```"

      ## Add mention
      data['text'] = data['text'] + "\n"

      ## Add assigned to
      sui_assigned_to = get_slack_user_id(issue.assigned_to_id, slack_info['token'])
      data['text'] = data['text'] + "<@#{sui_assigned_to}>" unless sui_assigned_to.blank?

      ## Add watcher
      issue.watcher_user_ids.each do |wid|
        next if issue.assigned_to_id == wid
        sui_watcher = get_slack_user_id(wid, slack_info['token'])
        data['text'] = data['text'] + " <@#{sui_watcher}>" unless sui_watcher.blank?
      end

      ## Don't send empty data
      return if details.blank? && issue.notes.blank?

      ## Post message data
      thread_ts = post_maessage(data['thread_ts'], slack_info['token'], data)
      if data['thread_ts'].blank? && !(thread_ts.blank?)
        set_slack_thread_ts(issue, thread_ts)
      end
    end

################################################################################
## Hook for controller_issue_relations_new_after_save_for_slack
################################################################################
    def controller_issue_relations_new_after_save_for_slack(context={})
      call_hook(:controller_issues_edit_after_save, context)
    end

################################################################################
## Hook for controller_issue_relations_move_after_save_for_slack
################################################################################
    def controller_issue_relations_move_after_save_for_slack(context={})
      call_hook(:controller_issues_edit_after_save, context)
    end

################################################################################
## Private Method
################################################################################
private

################################################################################
## Is Slack post message Disabled
################################################################################
    def is_user_disabled(user)
      ## check user
      return true if user.nil?

      ## check user custom field
      ucf_slack = UserCustomField.find_by_name("Slack Disabled")
      return true if ucf_slack.nil?

      ## check user custom value
      slack_disabled = user.custom_field_value(ucf_slack)

      return false if slack_disabled.nil?
      return true if slack_disabled == '1'

      return false
    end

################################################################################
## Is Slack post message Disabled
################################################################################
    def is_project_disabled(project)
      ## check project
      return true if project.nil?

      ## check project custom field
      pcf_slack = ProjectCustomField.find_by_name("Slack Disabled")
      return true if pcf_slack.nil?

      ## check project custom value
      slack_disabled = project.custom_field_value(pcf_slack)

      return false if slack_disabled.nil?
      return true if slack_disabled == '1'

      return false
    end

################################################################################
## Get Slack API URL
################################################################################
    def get_slack_api_url
      url = Setting.plugin_redmine_slack_integration['slack_api_url']
      url = 'https://slack.com/api' if url.blank?
      return url
    end

################################################################################
## Get Redmine Object URL
################################################################################
    def get_object_url(obj)
      routes = Rails.application.routes.url_helpers
      if Setting.host_name.to_s =~ /\A(https?\:\/\/)?(.+?)(\:(\d+))?(\/.+)?\z/i
        host, port, prefix = $2, $4, $5
        routes.url_for(obj.event_url({
          :host => host,
          :protocol => Setting.protocol,
          :port => port,
          :script_name => prefix
        }))
      else
        routes.url_for(obj.event_url({
          :host => Setting.host_name,
          :protocol => Setting.protocol
        }))
      end
    end

################################################################################
## Get Slack thread_ts
################################################################################
    def get_slack_thread_ts(issue)
      return nil if issue.nil?

      ## search issue custom field
      icf_slack_thread_ts = IssueCustomField.find_by_name("SLACK_THREAD_TS")
      return nil if icf_slack_thread_ts.nil?

      ## get issue custom value
      slack_thread_ts = issue.custom_field_value(icf_slack_thread_ts)

      return slack_thread_ts
    end

################################################################################
## Set Slack thread_ts
################################################################################
    def set_slack_thread_ts(issue, slack_thread_ts)
      return if issue.nil?
      return if slack_thread_ts.nil?

      ## search issue custom field
      icf_slack_thread_ts = IssueCustomField.find_by_name("SLACK_THREAD_TS")
      return if icf_slack_thread_ts.nil?

      ## get issue custom value
      icv_slack_thread_ts = issue.custom_value_for(icf_slack_thread_ts)
      return if icv_slack_thread_ts.nil?

      icv_slack_thread_ts.value = slack_thread_ts
      icv_slack_thread_ts.save
    end

################################################################################
## Get Slack Token and SLack Channel
################################################################################
    def get_slack_info(project)
      ## check project
      return nil if project.nil?

      ## used value from this project's custom field
      pcf_slack_token = ProjectCustomField.find_by_name("Slack Token")
      pcf_slack_channel = ProjectCustomField.find_by_name("Slack Channel")

      unless pcf_slack_token.nil? && pcf_slack_channel.nil?
        slack_token = project.custom_field_value(pcf_slack_token)
        slack_channel = project.custom_field_value(pcf_slack_channel)
        unless slack_token.blank? && slack_channel.blank?
          slack_info = {}
          slack_info['token'] = slack_token
          slack_info['channel'] = slack_channel
          return slack_info
        end
      end

      ## used value from parent project's custom field
      return get_slack_info(project.parent)
    end

################################################################################
## Get slack user ID
################################################################################
    def get_slack_user_id(user_id, token)
      ## check user_id
      return nil if user_id.nil?

      ## find the user
      user = User.find_by_id(user_id)
      return nil if user.nil?

      ## get mail account
      mail_account = user.mail.sub(/@.*$/, '')

      ## check user custom field
      ucf_slack_user_id = UserCustomField.find_by_name("Slack User ID")
      return mail_account if ucf_slack_user_id.nil?

      ## check user custom value
      cfv_slack_user_id = user.custom_field_value(ucf_slack_user_id)
      return cfv_slack_user_id unless cfv_slack_user_id.blank?

      ## lookup by email
      slack_user_id = lookup_by_email(user.mail, token)

      ## use mail account
      slack_user_id = mail_account if slack_user_id.nil?

      ## get user custom value
      ucv_slack_user_id = user.custom_value_for(ucf_slack_user_id)

      ## save slack user id
      unless ucv_slack_user_id.nil?
        ucv_slack_user_id.value = slack_user_id
        ucv_slack_user_id.save
      end

      return slack_user_id
    end

################################################################################
## Lookup slack user id by email from slack API
################################################################################
    def lookup_by_email(email, token)
      return nil if email.blank?

      ## Create URI
      uri = get_slack_api_url() + '/users.lookupByEmail'

      ## Create http header
      header = {}
      header['Content-Type'] = 'application/json; charset=UTF-8'
      header['Authorization'] = "Bearer #{token}"
      https_proxy = ENV['https_proxy'] || ENV['HTTPS_PROXY']

      ## Create http query
      query = {}
      query['email'] = email

      ## Get http response
      res = nil
      begin
        client = HTTPClient.new(https_proxy)
        client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
        res = client.get uri, :query => query, :header => header
      rescue Exception => e
        Rails.logger.warn("Cannot connect to #{url}")
        Rails.logger.warn(e)
      end

      return nil if res.nil?
      return nil if res.status_code.nil?
      return nil unless res.status_code == 200
      return nil if res.http_body.nil?
      return nil if res.http_body.content.nil?

      begin
        res_body = JSON.parse(res.http_body.content)
      rescue Exception => e
        Rails.logger.warn("Cannot parse JSON string: #{res.http_body.content}")
        Rails.logger.warn(e)
      end

      return nil if res_body['ok'].nil?
      return nil unless res_body['ok']
      return nil if res_body['user'].nil?
      return nil if res_body['user']['id'].nil?

      return res_body['user']['id']
    end

################################################################################
## Post message to Slack, and return slack thread_ts
################################################################################
    def post_maessage(thread_ts, token, data)
      Rails.logger.debug("Chat Data: #{data.to_json}")

      ## Create URI
      uri = get_slack_api_url() + '/chat.postMessage'

      ## Create http header
      header = {}
      header['Content-Type'] = 'application/json; charset=UTF-8'
      header['Authorization'] = "Bearer #{token}"
      https_proxy = ENV['https_proxy'] || ENV['HTTPS_PROXY']

      ## Post data
      res = nil
      begin
        client = HTTPClient.new(https_proxy)
        client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
        if thread_ts.blank?
          res = client.post uri, {:body => data.to_json, :header => header}
        else
          client.post_async uri, {:body => data.to_json, :header => header}
        end
      rescue Exception => e
        Rails.logger.warn("Cannot connect to #{url}")
        Rails.logger.warn(e)
      end

      return nil if res.nil?
      return nil if res.status_code.nil?
      return nil unless res.status_code == 200
      return nil if res.http_body.nil?
      return nil if res.http_body.content.nil?

      begin
        res_body = JSON.parse(res.http_body.content)
      rescue Exception => e
        Rails.logger.warn("Cannot parse JSON string: #{res.http_body.content}")
        Rails.logger.warn(e)
      end

      return nil if res_body.nil?

      return res_body['ts']
    end
  end
end
