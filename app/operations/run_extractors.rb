class RunExtractors
  attr_reader :workflow, :classification

  def initialize(workflow, classification)
    @workflow = workflow
    @classification = classification
  end

  def perform
    workflow.extractors.each do |id, extractor|
      data = extractor.extract(classification)

      extract = Extract.where(workflow_id: workflow.id, subject_id: classification.subject_id, classification_id: classification.id, extractor_id: id).first_or_initialize
      extract.data = data
      extract.save!
    end
  end
end
