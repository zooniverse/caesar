class SubjectRuleEffectPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      workflow_ids = Pundit.policy_scope!(credential, Workflow).pluck(:id)

      self.scope.joins(:subject_rule).where(subject_rules: { workflow_id: workflow_ids })
    end
  end

  # record passed in from controller is a workflow
  def index?
    if credential.admin?
      true
    else
      valid_workflow?(record, credential)
    end
  end

  # record passed in from controller is a workflow
  def show?
    index?
  end

  # record passed in from controller is a workflow
  def new?
    index?
  end

  # record passed in from controller is a subject_rule_effect
  def create?
    update?
  end

  # record passed in from controller is a subject_rule_effect
  def edit?
    if credential.admin?
      true
    else
      valid_associated_project?(record)
    end
  end

  # record passed in from controller is a subject_rule_effect
  def update?
    return false unless valid_credentials?
    return true if credential.admin?

    return false unless valid_associated_project?(record)
    valid_subject_set_or_collection?(record)
  end

  # record passed in from controller is a subject_rule_effect
  def destroy?
    edit?
  end

  private

  def valid_workflow?(workflow, credential)
    credential.project_ids.include?(workflow.project_id)
  end

  # pass in SubjectRuleEffect record
  def valid_associated_project?(record)
    subject_rule_project_id = record.subject_rule.workflow.project_id
    credential.project_ids.include?(subject_rule_project_id)
  end

  # pass in SubjectRuleEffect record
  def valid_subject_set_or_collection?(record)
    if record.effect.is_a?(Effects::AddSubjectToSet)
      subject_set = Effects.panoptes.subject_set(record.config['subject_set_id'])
      raise ActiveRecord::RecordNotFound if subject_set.nil?

      credential.project_ids.include?(subject_set['links']['project'])
    elsif record.effect.is_a?(Effects::AddSubjectToCollection)
      collection = Effects.panoptes.collection(record.config['collection_id'])
      raise ActiveRecord::RecordNotFound if collection.nil?

      credential.project_ids.include?(collection['links']['projects'].first)
    else
      true
    end
  end
end
