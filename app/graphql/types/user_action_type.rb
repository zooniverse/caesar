module Types
  class UserActionType < GraphQL::Schema::Object
    graphql_name "UserAction"

    field :id, ID, null: false

    field :classificationId, String, null: true, method: :classification_id
    field :classificationAt, Types::TimeType, null: true, method: :classification_at

    field :workflowId, ID, null: false, method: :workflow_id
    field :userId, ID, null: false, method: :user_id
    field :effectType, String, null: false, method: :effect_type
    field :status, Types::ActionStatusType, null: false

    field :config, Types::JsonType, null: true

    field :createdAt, Types::TimeType, null: false, method: :created_at
    field :updatedAt, Types::TimeType, null: false, method: :updated_at
    field :attemptedAt, Types::TimeType, null: true, method: :attempted_at
    field :completedAt, Types::TimeType, null: true, method: :completed_at
  end
end
