
class SubjectRuleEffectPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      workflow_ids = Pundit.policy_scope!(credential, Workflow).pluck(:id)

      self.scope.joins(:subject_rule).where(subject_rules: { workflow_id: workflow_ids })
    end
  end

  def index?
    update?
  end

  def create?
    update?
  end

  def update?
    return true if credential.admin?
    credential.project_ids.include?(record.workflow.project_id)
  end

  def destroy?
    credential.admin?
  end
end
