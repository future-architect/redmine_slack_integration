class CustomFieldsSlackUserId < ActiveRecord::Migration[4.2]

################################################################################
## Create custom field: Slack User ID
################################################################################
  def self.up
    if UserCustomField.find_by_name('Slack User ID').nil?
      UserCustomField.create(name: 'Slack User ID', field_format: 'string', visible: 0, default_value: '')
    end
  end

################################################################################
## Delete custom field: Slack User ID
################################################################################
  def self.down
    unless UserCustomField.find_by_name('Slack User ID').nil?
      UserCustomField.find_by_name('Slack User ID').delete
    end
  end
end
