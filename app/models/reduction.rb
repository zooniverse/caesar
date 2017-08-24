class Reduction < ApplicationRecord
  Type = GraphQL::ObjectType.define do
    name "Reduction"

    field :project_id, types.ID
    field :workflow_id, !types.ID
    field :subject_id, !types.ID
    field :reducer_id, types.String

    field :data, Types::JsonType

    field :created_at, !Types::TimeType
    field :updated_at, !Types::TimeType
  end

  belongs_to :workflow
  belongs_to :subject
end
