class SubjectAction < ApplicationRecord
  Type = GraphQL::ObjectType.define do
    name "SubjectAction"

    field :id, !types.ID

    field :classificationId, types.String, property: :classification_id
    field :classificationAt, Types::TimeType, property: :classification_at

    field :workflowId, !types.ID, property: :workflow_id
    field :subjectId, !types.ID, property: :subject_id
    field :effectType, !types.String, property: :effect_type
    field :status, !Types::ActionStatusType

    field :config, Types::JsonType

    field :createdAt, !Types::TimeType, property: :created_at
    field :updatedAt, !Types::TimeType, property: :updated_at
    field :attemptedAt, Types::TimeType, property: :attempted_at
    field :completedAt, Types::TimeType, property: :completed_at
  end

  enum :status, [:pending, :completed, :failed]

  belongs_to :workflow, counter_cache: true
  belongs_to :subject

  def perform
    effect.perform(workflow_id, subject_id)
    update! status: :completed, completed_at: Time.zone.now
  rescue StandardError
    update! status: :failed
    raise
  end

  def effect
    @effect ||= Effects[effect_type].new(config)
  end
end
