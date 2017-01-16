class ClassificationPipeline
  attr_reader :extractors, :reducers, :rules

  def initialize(extractors, reducers, rules)
    @extractors = extractors
    @reducers = reducers
    @rules = rules
  end

  def process(classification)
    extract(classification)
    reduce(classification)
    check_rules(classification)
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

  def reduce(classification)
    reducers.each do |id, reducer|
      data = reducer.process(extracts(classification))

      reduction = Reduction.where(workflow_id: classification.workflow_id, subject_id: classification.subject_id, reducer_id: id).first_or_initialize
      reduction.data = data
      reduction.save!
    end
  end

  def check_rules(classification)
    rules.process(classification.workflow_id, classification.subject_id, bindings(classification))
  end

  private

  def extracts(classification)
    Extract.where(workflow_id: classification.workflow_id, subject_id: classification.subject_id).order(classification_at: :desc).map(&:data)
  end

  def reductions(classification)
    Reduction.where(workflow_id: classification.workflow_id, subject_id: classification.subject_id)
  end

  def bindings(classification)
    MergesResults.merge(reductions(classification).map(&:data))
  end
end
