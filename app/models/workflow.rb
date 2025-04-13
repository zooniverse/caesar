class Workflow < ApplicationRecord
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

  enum rules_applied: %i[all_matching_rules first_matching_rule no_rules]
  enum status: { halted: 0, active: 1, paused: 2 }

  attr_accessor :rerun

  def self.accessible_by(credential)
    return none unless credential.logged_in?
    return none if credential.expired?
    return all if credential.admin?
    return none unless credential.project_ids.present?

    where(project_id: credential.project_ids)
  end

  def configured?
    (not (extractors&.empty? and reducers&.empty?))
  end

  def public_data?(type)
    case type
    when 'extracts'
      public_extracts?
    when 'user_reductions'
      public_reductions?
    when 'subject_reductions'
      public_reductions?
    else
      false
    end
  end

  def has_external_extractors?
    extractors_runner.has_external?
  end

  def extractors_runner
    @extractors_runner ||= RunsExtractors.new(extractors)
  end

  def rerun_extractors
    subject_ids = extracts.pluck(:subject_id).uniq

    # allow up to 100 rerun jobs per minute
    duration = (subject_ids.count / 100.0).ceil.minutes

    subject_ids.each do |subject_id|
      FetchClassificationsWorker.perform_in(rand(duration.to_i).seconds, id, subject_id, FetchClassificationsWorker.fetch_for_subject)
    end
  end

  def last_n_subjects(n, source)
    source.last(n*5).pluck(:subject_id).uniq.last(n)
  end

  def random_n_subjects(n)
    (extracts.pluck(:subject_id).sample(n*3) + subject_reductions.pluck(:subject_id).sample(n*3)).uniq.sample(n)
  end
end
