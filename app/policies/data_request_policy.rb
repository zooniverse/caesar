class DataRequestPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      workflow_ids = Pundit.policy_scope!(credential, Workflow).pluck(:id)

      scope = self.scope.joins(:workflow).references(:workflows)
      scope.where(workflow_id: workflow_ids).or(scope.where(public: true))
    end
  end

  def create?
    return true if credential.admin?
    return true if record.extracts? && record.workflow.public_extracts
    return true if record.reductions? && record.workflow.public_reductions

    credential.project_ids.include?(record.workflow.project_id)
  end

  def update?
    return true if credential.admin?

    credential.project_ids.include?(record.workflow.project_id)
  end

  def destroy?
    credential.admin?
  end
end
