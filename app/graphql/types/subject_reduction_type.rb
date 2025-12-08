# frozen_string_literal: true

module Types
  # Subject reduction GraphQL type.
  class SubjectReductionType < GraphQL::Schema::Object
    graphql_name 'SubjectReduction'

    field :projectId, ID, null: true, method: :project_id
    field :workflowId, ID, null: false, method: :workflow_id
    field :subjectId, ID, null: false, method: :subject_id
    field :reducerKey, String, null: true, method: :reducer_key

    field :data, Types::JsonType, null: true

    field :createdAt, Types::TimeType, null: false, method: :created_at
    field :updatedAt, Types::TimeType, null: false, method: :updated_at
  end
end
