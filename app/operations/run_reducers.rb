class RunReducers
  attr_reader :workflow, :subject_id

  def initialize(workflow, subject_id)
    @workflow = workflow
    @subject_id = subject_id
  end

  def perform
    workflow.reducers.each do |id, reducer|
      data = reducer.reduce(extracts)

      reduction = Reduction.where(workflow_id: workflow_id, subject_id: subject_id, reducer_id: id).first_or_initialize
      reduction.data = data
      reduction.save!
    end
  end

  def extracts
    Extract.where(workflow_id: workflow_id, subject_id: subject_id).map(&:data)
  end

  def workflow_id
    workflow.id
  end
end
