class UpdateWorkflowCache
  attr_reader :attributes

  def initialize(attributes)
    @attributes = attributes.with_indifferent_access
  end

  def perform
    workflow = Workflow.where(id: attributes[:id]).first_or_initialize
    workflow.extractors_config = attributes[:retirement][:nero][:extractors]
    workflow.reducers_config = attributes[:retirement][:nero][:reducers]
    workflow.rules_config = attributes[:retirement][:nero][:rules]
    workflow.save!
  end
end
