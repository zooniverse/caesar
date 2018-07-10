class UserReductionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      public_workflows = Workflow.where(public_reductions: true).pluck(:id)
      workflow_ids = (Pundit.policy_scope!(credential, Workflow).pluck(:id) + public_workflows).uniq
      self.scope.where(reducible_type: 'Workflow', reducible_id: workflow_ids)
    end
  end

  def create?
    update?
  end

  def update?
    return true if credential.admin?
    credential.project_ids.include?(record.reducible.project_id)
  end

  def destroy?
    credential.admin?
  end
end
