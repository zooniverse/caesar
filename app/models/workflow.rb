class Workflow < ApplicationRecord
  def self.accessible_by(credential)
    return none unless credential.logged_in?
    return none if credential.expired?
    return all if credential.admin?
    return none unless credential.project_ids.present?

    where(project_id: credential.project_ids)
  end

  def enabled?
    extractors_config.present? || reducers_config.present? || rules_config.present?
  end

  def update_cache(config)
    if workflow.new_record? || workflow.updated_at < attributes[:updated_at]
      workflow.extractors_config = config[:extractors] || {}
      workflow.reducers_config = config[:reducers] || {}
      workflow.rules_config = config[:rules] || []
      workflow.updated_at = attributes[:updated_at] || Time.zone.now
      workflow.webhooks = config[:webhooks] || []
      workflow.save!
    end
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
end
