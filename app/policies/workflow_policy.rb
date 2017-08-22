class WorkflowPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless credential.logged_in?
      return scope.none if credential.expired?
      return scope.all if credential.admin?
      return scope.none unless credential.project_ids.present?

      scope.where(project_id: credential.project_ids)
    end
  end

  def index?
    true
  end

  def create?
    show?
  end

  def update?
    show?
  end

  def destroy?
    credential.admin?
  end
end
