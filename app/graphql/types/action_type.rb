ActionStatus = GraphQL::EnumType.define do
  name "ActionStatus"
  description "Status of a pending or performed action"

  value("pending", "Action is not performed yet")
  value("completed", "Action has been performed successfully")
  value("failed", "Action failed even after retries")
end

Types::ActionType = GraphQL::ObjectType.define do
  name "Action"

  field :classification_id, types.String
  field :classification_at, Types::TimeType

  field :workflow_id, !types.ID
  field :subject_id, !types.ID
  field :effect_type, !types.String
  field :status, !ActionStatus

  field :config, Types::JsonType

  field :created_at, !Types::TimeType
  field :updated_at, !Types::TimeType
  field :attempted_at, Types::TimeType
  field :completed_at, Types::TimeType
end
