class Action < ApplicationRecord
  enum status: [:pending, :completed, :failed]

  belongs_to :workflow
  belongs_to :subject

  def perform
    effect.perform(workflow_id, subject_id)
    update! status: :completed, completed_at: Time.zone.now
  end

  def effect
    @effect ||= Effects[effect_type].new(config)
  end
end
