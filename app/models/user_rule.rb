class UserRule < ApplicationRecord
  belongs_to :workflow
  has_many :user_rule_effects
end
