class Action < ApplicationRecord
  Status = GraphQL::EnumType.define do
    name "ActionStatus"
    description "Status of a pending or performed action"

    value("pending", "Action is not performed yet")
    value("completed", "Action has been performed successfully")
    value("failed", "Action failed even after retries")
  end

  Type = GraphQL::ObjectType.define do
    name "Action"

    field :classification_id, types.String
    field :classification_at, Types::TimeType

    field :workflow_id, !types.ID
    field :subject_id, !types.ID
    field :effect_type, !types.String
    field :status, !Status

    field :config, Types::JsonType

    field :created_at, !Types::TimeType
    field :updated_at, !Types::TimeType
    field :attempted_at, Types::TimeType
    field :completed_at, Types::TimeType
  end

  enum status: [:pending, :completed, :failed]

  belongs_to :workflow
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
