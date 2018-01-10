class UserAction < ApplicationRecord
  enum status: [:pending, :completed, :failed]
  belongs_to :workflow

  def perform
    effect.perform(workflow_id, user_id)
    update! status: :completed, completed_at: Time.zone.now
  rescue StandardError
    update! status: :failed
    raise
  end

  def effect
    @effect ||= Effects[effect_type].new(config)
  end
end
