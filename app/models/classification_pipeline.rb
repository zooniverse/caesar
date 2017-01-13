class ClassificationPipeline
  attr_reader :extractors, :reducers, :rules

  def initialize(extractors, reducers, rules)
    @extractors = extractors
    @reducers = reducers
    @rules = rules
  end

  def process(classification)
    extractors.each do |id, extractor|
      data = extractor.process(classification)

      extract = Extract.where(workflow_id: classification.workflow_id, subject_id: classification.subject_id, classification_id: classification.id, extractor_id: id).first_or_initialize
      extract.data = data
      extract.save!
    end

    reducers.each do |id, reducer|
      data = reducer.process(extracts(classification))

      reduction = Reduction.where(workflow_id: classification.workflow_id, subject_id: classification.subject_id, reducer_id: id).first_or_initialize
      reduction.data = data
      reduction.save!
    end

    rules.process(classification.workflow_id, classification.subject_id, bindings(classification))
  end

  def extracts(classification)
    Extract.where(workflow_id: classification.workflow_id, subject_id: classification.subject_id).map(&:data)
  end

  def reductions(classification)
    Reduction.where(workflow_id: classification.workflow_id, subject_id: classification.subject_id)
  end

  def bindings(classification)
    MergesResults.merge(reductions(classification).map(&:data))
  end
end
