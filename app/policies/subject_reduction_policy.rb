class SubjectReductionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      workflow_ids = Pundit.policy_scope!(credential, Workflow).pluck(:id)

      # This is complicated by the polymorphic relationship's inability to LEFT JOIN.
      # scope = self.scope.joins(:workflow).references(:workflows)
      # scope.where(workflow_id: workflow_ids).or(scope.where(workflows: {public_reductions: true}))

      # This doesn't include public reductions
      scope = self.scope.where(reducible_id: workflow_ids)
    end
  end

  def create?
    update?
  end

  def update?
    return true if credential.admin?
    # TODO: Either projects respond to #project_id also or this gets a switch
    credential.project_ids.include?(record.reducible.project_id)
  end

  def destroy?
    credential.admin?
  end
end
