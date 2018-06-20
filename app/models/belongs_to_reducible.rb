module BelongsToReducible 
  extend ActiveSupport::Concern

  included do
    belongs_to :reducible, polymorphic: true, optional: true
    before_save :set_workflow
  end

  def set_reducible
    self.reducible_id = workflow.id
    self.reducible_type = "workflow" 
  end

  def set_workflow
    self.workflow_id = reducible.id
  end
end
