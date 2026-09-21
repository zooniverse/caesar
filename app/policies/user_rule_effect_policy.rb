class UserRuleEffectPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      workflow_ids = Pundit.policy_scope!(credential, Workflow).pluck(:id)

      self.scope.joins(:user_rule).where(user_rules: { workflow_id: workflow_ids })
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

    credential.project_ids.include?(record.user_rule.workflow.project_id)
  end

  def destroy?
    return true if credential.admin?

    credential.project_ids.include?(record.user_rule.workflow.project_id)
  end
end
