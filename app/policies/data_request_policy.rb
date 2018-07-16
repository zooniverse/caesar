class DataRequestPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      workflow_ids = Pundit.policy_scope!(credential, Workflow).pluck(:id)
      self.scope.where(exportable_type: 'Workflow', exportable_id: workflow_ids)
    end
  end

  def create?
    return true if credential.admin?
    return true if record.extracts? && record.exportable.public_extracts
    return true if record.reductions? && record.exportable.public_reductions

    # TODO: Projects need to respond to project_id or this becomes a conditional
    credential.project_ids.include?(record.exportable.project_id)
  end

  def update?
    return true if credential.admin?

    credential.project_ids.include?(record.exportable.project_id)
  end

  def destroy?
    credential.admin?
  end
end
