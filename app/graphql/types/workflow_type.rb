# frozen_string_literal: true

module Types
  class WorkflowType < GraphQL::Schema::Object
    graphql_name 'Workflow'

    field :id, ID, null: false
    field :createdAt, Types::TimeType, null: false, method: :created_at
    field :updatedAt, Types::TimeType, null: false, method: :updated_at

    field :extracts, [Types::ExtractType], null: true do
      argument :subjectId, ID, required: true
      argument :extractorKey, String, required: false
    end

    field :reductions, [Types::SubjectReductionType], null: true do
      argument :subjectId, ID, required: true
      argument :reducerKey, String, required: false
    end

    field :subject_reductions, [Types::SubjectReductionType], null: true, camelize: false do
      argument :subjectId, ID, required: true
      argument :reducerKey, String, required: false
    end

    field :subject_actions, [Types::SubjectActionType], null: true, camelize: false do
      argument :subjectId, ID, required: true
    end

    field :user_reductions, [Types::UserReductionType], null: true, camelize: false do
      argument :userId, ID, required: true
      argument :reducerKey, String, required: false
    end

    field :user_actions, [Types::UserActionType], null: true, camelize: false do
      argument :userId, ID, required: true
    end

    field :data_requests, [Types::DataRequestType], null: true, camelize: false

    def extracts(subjectId:, extractorKey: nil)
      scope = Pundit.policy_scope!(context[:credential], Extract)
      scope = scope.where(workflow_id: object.id)
      scope = scope.where(subject_id: subjectId)
      scope = scope.where(extractor_key: extractorKey) if extractorKey
      scope
    end

    def reductions(subjectId:, reducerKey: nil)
      scope = Pundit.policy_scope!(context[:credential], SubjectReduction)
      scope = scope.where(workflow_id: object.id)
      scope = scope.where(subject_id: subjectId)
      scope = scope.where(reducer_key: reducerKey) if reducerKey
      scope
    end

    def subject_reductions(subjectId:, reducerKey: nil)
      reductions(subjectId: subjectId, reducerKey: reducerKey)
    end

    def subject_actions(subjectId:)
      scope = Pundit.policy_scope!(context[:credential], SubjectAction)
      scope.where(workflow_id: object.id, subject_id: subjectId)
    end

    def user_reductions(userId:, reducerKey: nil)
      scope = Pundit.policy_scope!(context[:credential], UserReduction)
      scope = scope.where(workflow_id: object.id)
      scope = scope.where(user_id: userId)
      scope = scope.where(reducer_key: reducerKey) if reducerKey
      scope
    end

    def user_actions(userId:)
      scope = Pundit.policy_scope!(context[:credential], UserAction)
      scope.where(workflow_id: object.id, user_id: userId)
    end

    def data_requests
      scope = Pundit.policy_scope!(context[:credential], DataRequest)
      # Data requests are polymorphic on exportable (Workflow/Project), so filter on the exportable id/type.
      scope.where(exportable_id: object.id, exportable_type: 'Workflow')
    end
  end
end
