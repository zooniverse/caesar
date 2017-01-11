class RunRules
  attr_reader :workflow, :subject_id

  def initialize(workflow, subject_id)
    @workflow = workflow
    @subject_id = subject_id
  end

  def perform
    workflow.rules.apply(bindings)
  end

  def bindings
    MergesResults.merge(reductions.map(&:data))
  end

  def reductions
    Reduction.where(workflow_id: workflow_id, subject_id: subject_id)
  end

  def workflow_id
    workflow.id
  end
end
