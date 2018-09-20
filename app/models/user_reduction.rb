class UserReduction < ApplicationRecord
  include BelongsToReducibleCached

  Type = GraphQL::ObjectType.define do
    name "UserReduction"

    field :projectId, types.ID, property: :project_id
    field :workflowId, !types.ID, property: :workflow_id
    field :userId, !types.ID, property: :user_id
    field :reducerKey, types.String, property: :reducer_key

    field :data, Types::JsonType

    field :createdAt, !Types::TimeType, property: :created_at
    field :updatedAt, !Types::TimeType, property: :updated_at
  end

  has_and_belongs_to_many_with_deferred_save :extracts
end
