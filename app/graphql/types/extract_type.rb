# frozen_string_literal: true

module Types
  # Extract GraphQL type.
  class ExtractType < GraphQL::Schema::Object
    graphql_name 'Extract'

    field :id, ID, null: false
    field :classificationId, String, null: true, method: :classification_id
    field :classificationAt, Types::TimeType, null: true, method: :classification_at

    field :workflowId, ID, null: false, method: :workflow_id
    field :subjectId, ID, null: false, method: :subject_id
    field :extractorKey, String, null: false, method: :extractor_key
    field :userId, ID, null: true, method: :user_id

    field :data, Types::JsonType, null: true

    field :createdAt, Types::TimeType, null: false, method: :created_at
    field :updatedAt, Types::TimeType, null: false, method: :updated_at
  end
end
