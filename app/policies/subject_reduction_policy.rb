class SubjectReductionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      workflow_ids = Pundit.policy_scope!(credential, Workflow).pluck(:id)

      scope = self.scope.joins(:workflow).references(:workflows)
      scope.where(workflow_id: workflow_ids).or(scope.where(workflows: {public_reductions: true}))
    end
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
