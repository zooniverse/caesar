module Types
  class UserReductionType < GraphQL::Schema::Object
    graphql_name 'UserReduction'

    field :projectId, ID, null: true, method: :project_id
    field :workflowId, ID, null: false, method: :workflow_id
    field :userId, ID, null: false, method: :user_id
    field :reducerKey, String, null: true, method: :reducer_key

    field :data, Types::JsonType, null: true

    field :createdAt, Types::TimeType, null: false, method: :created_at
    field :updatedAt, Types::TimeType, null: false, method: :updated_at
  end
end
