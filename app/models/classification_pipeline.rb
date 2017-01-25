class ClassificationPipeline
  attr_reader :extractors, :reducers, :rules

  def initialize(extractors, reducers, rules)
    @extractors = extractors
    @reducers = reducers
    @rules = rules
  end

  def process(classification)
    extract(classification)
    reduce(classification.workflow_id, classification.subject_id)
    check_rules(classification.workflow_id, classification.subject_id)
  end

  def extract(classification)
    extractors.each do |id, extractor|
      data = extractor.process(classification)

      extract = Extract.where(workflow_id: classification.workflow_id, subject_id: classification.subject_id, classification_id: classification.id, extractor_id: id).first_or_initialize
      extract.project_id = classification.project_id
      extract.user_id = classification.user_id
      extract.classification_at = classification.created_at
      extract.data = data
      extract.save!
    end
  end

  def reduce(workflow_id, subject_id)
    reducers.each do |id, reducer|
      data = reducer.process(extracts(workflow_id, subject_id))

      reduction = Reduction.where(workflow_id: workflow_id, subject_id: subject_id, reducer_id: id).first_or_initialize
      reduction.data = data
      reduction.save!
    end
  end

  def check_rules(workflow_id, subject_id)
    return unless rules.present?
    rules.process(workflow_id, subject_id, bindings(workflow_id, subject_id))
  end

  private

  def extracts(workflow_id, subject_id)
    Extract.where(workflow_id: workflow_id, subject_id: subject_id).order(classification_at: :desc).map(&:data)
  end

  def bindings(workflow_id, subject_id)
    MergesResults.merge(reductions(workflow_id, subject_id).map(&:data))
  end

  def reductions(workflow_id, subject_id)
    Reduction.where(workflow_id: workflow_id, subject_id: subject_id)
  end
end
