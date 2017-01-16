class UpdateWorkflowCache
  attr_reader :attributes

  def initialize(attributes)
    @attributes = attributes.with_indifferent_access
  end

  def perform
    nero_config = attributes.fetch(:retirement, {}).fetch(:nero, {})

    workflow = Workflow.where(id: attributes[:id]).first_or_initialize
    workflow.extractors_config = nero_config[:extractors] || {}
    workflow.reducers_config = nero_config[:reducers] || {}
    workflow.rules_config = nero_config[:rules] || []
    workflow.save!
  end
end
