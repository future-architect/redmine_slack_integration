module RedmineSlackIntegration

################################################################################
## Expand IssueRelationsController
################################################################################
  module IssueRelationsControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      ## Same as typing in the class
      base.class_eval do
        unloadable
        after_action :after_action_create, :only => :create
        after_action :after_action_destroy, :only => :destroy
      end
    end

################################################################################
## Expand InstanceMethods
################################################################################
    module InstanceMethods

################################################################################
## Call an action after issue_relation is created
################################################################################
      def after_action_create
        return if @relation.nil?
        return if @relation.id.nil?
        return if @issue.nil?

        call_hook(:controller_issue_relations_new_after_save_for_slack, { :params => params, :issue => @issue, :journal => @issue.current_journal })
      end

################################################################################
## Call an action after issue_relation is destroyed
################################################################################
      def after_action_destroy
        return if @relation.nil?
        return if @relation.id.nil?

        issue_relation = nil
        begin
          issue_relation = IssueRelation.find(@relation.id)
        rescue ActiveRecord::RecordNotFound
          issue_relation = nil
        end
        return unless issue_relation.nil?

        issue_from = @relation.issue_from
        issue_to = @relation.issue_to

        call_hook(:controller_issue_relations_move_after_save_for_slack, { :params => params, :issue => issue_from, :journal => issue_from.current_journal })
        call_hook(:controller_issue_relations_move_after_save_for_slack, { :params => params, :issue => issue_to, :journal => issue_to.current_journal })
      end

    end
  end
end

################################################################################
## Include IssueRelationsController
################################################################################
IssueRelationsController.send(:include, RedmineSlackIntegration::IssueRelationsControllerPatch)
