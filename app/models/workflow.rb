class Workflow < ApplicationRecord
  def self.accessible_by(credential)
    return none unless credential.logged_in?
    return none if credential.expired?
    return all if credential.admin?
    return none unless credential.project_ids.present?

    where(project_id: credential.project_ids)
  end

  has_many :data_requests

  def subscribers?
    webhooks&.size > 0
  end

  def classification_pipeline
    ClassificationPipeline.new(extractors, reducers, rules)
  end

  def extractors
    Extractors::FromConfig.build_many(extractors_config)
  end

  def reducers
    Reducers::FromConfig.build_many(reducers_config)
  end

  def rules
    Rules::Engine.new(rules_config)
  end

  def webhooks
    Webhooks::Engine.new(webhooks_config)
  end

  def configured?
    (not (extractors&.empty? and reducers&.empty?)) and
      (rules&.present? and subscribers?)
  end

  def subscribers?
    webhooks.size > 0
  end

end
