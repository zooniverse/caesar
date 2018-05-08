class SubjectReduction < ApplicationRecord
  Type = GraphQL::ObjectType.define do
    name "SubjectReduction"

    field :reducibleId, !types.ID, property: :reducible_id
    field :subjectId, !types.ID, property: :subject_id
    field :reducerKey, types.String, property: :reducer_key

    field :data, Types::JsonType

    field :createdAt, !Types::TimeType, property: :created_at
    field :updatedAt, !Types::TimeType, property: :updated_at
  end

  belongs_to :reducible, polymorphic: true
  belongs_to :subject
  has_and_belongs_to_many_with_deferred_save :extract
end
