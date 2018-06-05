class UserReductionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      workflow_ids = Pundit.policy_scope!(credential, Workflow).pluck(:id)
      project_ids = credential.project_ids

      scope = self.scope.joins(:reducible).references(:reducibles)
      scope = scope.where(reducible_id: workflow_ids, reducible_type: 'Workflow')
        .or(scope.where(reducible_id: project_ids, reducible_type: 'Project'))
        .or(UserReduction.where(reducible: {public_reductions: true}))
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
