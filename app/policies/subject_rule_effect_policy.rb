class SubjectRuleEffectPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      workflow_ids = Pundit.policy_scope!(credential, Workflow).pluck(:id)

      self.scope.joins(:subject_rule).where(subject_rules: { workflow_id: workflow_ids })
    end
  end

  def index?
    # record is a workflow from the controller
    if credential.admin?
      true
    else
      credential.project_ids.include?(record.project_id)
    end
  end

  def create?
    update?
  end

  def edit?
    # record is a subject_rule_effect from the controller
    if credential.admin?
      true
    else
      subject_rule_project_id = record.subject_rule.workflow.project_id
      credential.project_ids.include?(subject_rule_project_id)
    end
  end

  def update?
    return true if credential.admin?
    return false unless valid_credentials?

    if record.config.key?('subject_set_id')
      subject_set = Effects.panoptes.subject_set(record.config['subject_set_id'])
      raise ActiveRecord::RecordNotFound if subject_set.nil?

      credential.project_ids.include?(subject_set['links']['project'])
    elsif record.config.key?('collection_id')
      collection = Effects.panoptes.collection(record.config[:subject_set_id])
      raise ActiveRecord::RecordNotFound if collection.nil?

      credential.project_ids.include?(collection['links']['projects'].first)
    else
      true
    end
  end

  def destroy?
    # record is a subject_rule_effect from the controller
    if credential.admin?
      true
    else
      subject_rule_project_id = record.subject_rule.workflow.project_id
      credential.project_ids.include?(subject_rule_project_id)
    end
  end
end
