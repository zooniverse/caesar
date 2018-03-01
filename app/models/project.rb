class Project < ApplicationRecord
  include Configurable

  has_many :extractors
  has_many :reducers, as: :configurable
  has_many :subject_rules
  has_many :user_rules

  has_many :extracts
  has_many :subject_reductions
  has_many :user_reductions
  has_many :subject_actions
  has_many :user_actions
  has_many :data_requests

end
