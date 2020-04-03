class SubjectRuleEffectPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      workflow_ids = Pundit.policy_scope!(credential, Workflow).pluck(:id)

      self.scope.joins(:subject_rule).where(subject_rules: { workflow_id: workflow_ids })
    end
  end

  def index?
    if credential.admin?
      true
    else
      subject_rule_project_id = record.subject_rule.workflow.project_id
      credential.project_ids.include?(subject_rule_project_id)
    end
  end

  def create?
    update?
  end

  def update?
    if credential.admin?
      true
    else
      binding.pry
      # subject_rule_project_id = record.subject_rule.workflow.project_id
      # credential.project_ids.include?(subject_rule_project_id)
      #
      # this is a good place to check the defined subect set id in the
      # rule effect belongs to the scoped credential project ids using the API client

      # temporarily disable the ability for users to create/update
      # subject rule effects
      false
    end
  end

  def destroy?
    update?
  end
end
