class UserProfile < ApplicationRecord
  belongs_to :workflow

  def self.before(workflow_id, user_id, generator, as_of)
    self \
      .where(workflow_id: workflow_id, user_id: user_id, generator: generator)
      .where("as_of < ?", as_of)
      .order("as_of DESC")
      .first
  end
end
