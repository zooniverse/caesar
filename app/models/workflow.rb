class Workflow < ApplicationRecord
  def self.accessible_by(current_user)
    return none unless current_user.logged_in?
    return all if current_user.admin?
    return none unless current_user.project_ids.present?

    where(project_id: current_user.project_ids)
  end

  def self.update_cache(attributes)
    attributes = attributes.with_indifferent_access if attributes.is_a?(Hash)
    config = attributes[:nero_config] || {}

    workflow = Workflow.where(id: attributes[:id]).first_or_initialize

    if workflow.new_record? || workflow.updated_at < attributes[:updated_at]
      workflow.project_id = attributes[:project_id]
      workflow.extractors_config = config[:extractors] || {}
      workflow.reducers_config = config[:reducers] || {}
      workflow.rules_config = config[:rules] || []
      workflow.updated_at = attributes[:updated_at] || Time.zone.now
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
end
