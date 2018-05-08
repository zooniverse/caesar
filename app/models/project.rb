class Project < ApplicationRecord
  include Configurable

  has_many :extractors
  has_many :reducers, as: :reducible
  has_many :subject_rules
  has_many :user_rules

  has_many :extracts
  has_many :subject_reductions
  has_many :user_reductions
  has_many :subject_actions
  has_many :user_actions
  has_many :data_requests

  def classification_pipeline
    ClassificationPipeline.new(self,
                               extractors,
                               reducers,
                               subject_rules.rank(:row_order),
                               user_rules.rank(:row_order),
                               rules_applied)
  end

  def has_reducers?
    !reducers&.empty?
  end
end
