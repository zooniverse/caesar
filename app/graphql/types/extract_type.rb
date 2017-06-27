Types::ExtractType = GraphQL::ObjectType.define do
  name "Extract"

  field :classification_id, types.String
  field :classification_at, Types::TimeType

  field :project_id, types.ID
  field :workflow_id, !types.ID
  field :subject_id, !types.ID
  field :extractor_id, !types.ID
  field :user_id, types.ID

  field :data, Types::JsonType

  field :created_at, !Types::TimeType
  field :updated_at, !Types::TimeType
end
