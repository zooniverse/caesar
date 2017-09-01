class Extract < ApplicationRecord
  Type = GraphQL::ObjectType.define do
    name "Extract"

    field :classificationId, types.String, property: :classification_id
    field :classificationAt, Types::TimeType, property: :classification_at

    field :workflowId, !types.ID, property: :workflow_id
    field :subjectId, !types.ID, property: :subject_id
    field :extractorKey, !types.String, property: :extractor_key
    field :userId, types.ID, property: :user_id

    field :data, Types::JsonType

    field :createdAt, !Types::TimeType, property: :created_at
    field :updatedAt, !Types::TimeType, property: :updated_at
  end

  belongs_to :workflow
  belongs_to :subject
end
