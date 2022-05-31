class PopulateCustomFields < ActiveRecord::Migration[4.2]

################################################################################
## Create custom field
################################################################################
  def self.up
    if ProjectCustomField.find_by_name('Slack Token').nil?
      ProjectCustomField.create(name: 'Slack Token', field_format: 'string', visible: 0, default_value: '')
    end
    if ProjectCustomField.find_by_name('Slack Channel').nil?
      ProjectCustomField.create(name: 'Slack Channel', field_format: 'string', visible: 0, default_value: '')
    end
    if ProjectCustomField.find_by_name('Slack Disabled').nil?
      ProjectCustomField.create(name: 'Slack Disabled', field_format: 'bool', visible: 0, default_value: 0, is_required: 0, edit_tag_style: 'check_box')
    end
    if UserCustomField.find_by_name('Slack Disabled').nil?
      UserCustomField.create(name: 'Slack Disabled', field_format: 'bool', visible: 0, default_value: 0, is_required: 0, edit_tag_style: 'check_box')
    end
    if IssueCustomField.find_by_name('SLACK_THREAD_TS').nil?
      icf = IssueCustomField.create(name: 'SLACK_THREAD_TS', field_format: 'string', default_value: '', is_for_all: 1)
      icf.trackers = Tracker.all
      icf.save
    end
  end

################################################################################
## Delete custom field
################################################################################
  def self.down
    unless ProjectCustomField.find_by_name('Slack Token').nil?
      ProjectCustomField.find_by_name('Slack Token').delete
    end
    unless ProjectCustomField.find_by_name('Slack Channel').nil?
      ProjectCustomField.find_by_name('Slack Channel').delete
    end
    unless ProjectCustomField.find_by_name('Slack Disabled').nil?
      ProjectCustomField.find_by_name('SLack Disabled').delete
    end
    unless UserCustomField.find_by_name('Slack Disabled').nil?
      UserCustomField.find_by_name('SLack Disabled').delete
    end
    unless IssueCustomField.find_by_name('SLACK_THREAD_TS').nil?
      IssueCustomField.find_by_name('SLACK_THREAD_TS').delete
    end
  end
end
