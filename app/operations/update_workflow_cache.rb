class UpdateWorkflowCache
  attr_reader :attributes

  def initialize(attributes)
    @attributes = attributes.with_indifferent_access
  end

  def perform
    workflow = Workflow.where(id: attributes[:id]).first_or_initialize
    workflow.retirement = attributes[:retirement]
    workflow.save!
  end
end
