class Project < ApplicationRecord
  include Configurable
  include IsReducible

  has_many :extractors
  has_many :reducers, as: :reducible
  has_many :subject_rules
  has_many :user_rules

  has_many :extracts
  has_many :subject_reductions, as: :reducible
  has_many :user_reductions, as: :reducible
  has_many :subject_actions
  has_many :user_actions
  has_many :data_requests, as: :exportable

  enum status: { paused: 0, active: 1 }

  attr_accessor :rerun

  def self.accessible_by(credential)
    return none unless credential.logged_in?
    return none if credential.expired?
    return all if credential.admin?
    return none unless credential.project_ids.present?

    where(id: credential.project_ids)
  end

  def has_reducers?
    !reducers&.empty?
  end

  def public_data?(type)
    public_reductions?
  end

  def project_id
    id
  end

  def last_n_subjects(n, source)
    source.last(n*5).pluck(:subject_id).uniq.last(n)
  end

  def random_n_subjects(n)
    subject_reductions.pluck(:subject_id).sample(n*5).uniq.sample(n)
  end
end
