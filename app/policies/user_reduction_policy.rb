class UserReductionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      public_workflows = Workflow.where(public_reductions: true).pluck(:id)
      public_projects = Project.where(public_reductions: true).pluck(:id)

      workflow_ids = (Pundit.policy_scope!(credential, Workflow).pluck(:id) + public_workflows).uniq
      project_ids = (Pundit.policy_scope!(credential, Project).pluck(:id) + public_projects).uniq

      self.scope.where(reducible_type: 'Workflow', reducible_id: workflow_ids)
        .or(self.scope.where(reducible_type: 'Project', reducible_id: project_ids))
    end
  end

  def create?
    update?
  end

  def update?
    return true if credential.admin?
    credential.project_ids.include?(record.reducible.project_id)
  end

  def current_user_reductions?
    return true if credential.admin?
    record.all? { |reduction| credential.current_user_id == reduction.user_id }
  end

  def destroy?
    credential.admin?
  end
end
