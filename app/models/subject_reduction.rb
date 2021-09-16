class SubjectReduction < ApplicationRecord
  include BelongsToReducibleCached

  Type = GraphQL::ObjectType.define do
    name "SubjectReduction"

    field :projectId, types.ID, property: :project_id
    field :workflowId, !types.ID, property: :workflow_id
    field :subjectId, !types.ID, property: :subject_id
    field :reducerKey, types.String, property: :reducer_key

    field :data, Types::JsonType

    field :createdAt, !Types::TimeType, property: :created_at
    field :updatedAt, !Types::TimeType, property: :updated_at
  end

  belongs_to :subject
  has_and_belongs_to_many_with_deferred_save :extracts

  def prepare
    {
      id: id,
      reducible: { id: reducible_id, type: reducible_type },
      data: data,
      subject: subject.attributes,
      reducer_key: reducer_key,
      created_at: created_at,
      updated_at: updated_at
    }.with_indifferent_access
  end
end
