class Workflow < ApplicationRecord
  def self.update_cache(attributes)
    attributes = attributes.with_indifferent_access
    nero_config = attributes.fetch(:retirement, {}).fetch(:nero, {})

    workflow = Workflow.where(id: attributes[:id]).first_or_initialize
    workflow.extractors_config = nero_config[:extractors] || {}
    workflow.reducers_config = nero_config[:reducers] || {}
    workflow.rules_config = nero_config[:rules] || []
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
