class Workflow < ApplicationRecord
  def self.update_cache(attributes)
    attributes = attributes.with_indifferent_access
    config = attributes.fetch(:retirement, {}).fetch(:caesar, {})

    workflow = Workflow.where(id: attributes[:id]).first_or_initialize
    workflow.extractors_config = config[:extractors] || {}
    workflow.reducers_config = config[:reducers] || {}
    workflow.rules_config = config[:rules] || []
    workflow.save!
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
