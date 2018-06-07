class UserReduction < ApplicationRecord
  include BelongsToReducible

  Type = GraphQL::ObjectType.define do
    name "SubjectReduction"

    field :projectId, types.ID, property: :project_id
    field :workflowId, !types.ID, property: :workflow_id
    field :userId, !types.ID, property: :user_id
    field :reducerKey, types.String, property: :reducer_key

    field :data, Types::JsonType

    field :createdAt, !Types::TimeType, property: :created_at
    field :updatedAt, !Types::TimeType, property: :updated_at
  end

  belongs_to :workflow
  has_and_belongs_to_many_with_deferred_save :extracts
end
