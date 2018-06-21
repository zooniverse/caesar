class UserReductionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      workflow_ids = Pundit.policy_scope!(credential, Workflow).pluck(:id)

      # scope = self.scope.joins(:workflow).references(:workflows)
      # scope.where(workflow_id: workflow_ids).or(scope.where(workflows: {public_reductions: true}))

      # Temporary, see subject_reduction_policy.rb
      scope = self.scope.where(reducible_id: workflow_ids)
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
