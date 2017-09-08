class Workflow::ConvertLegacyExtractorsConfig
  attr_reader :workflow

  def initialize(workflow)
    @workflow = workflow
  end

  def update(config)
    return if config.nil?

    workflow.extractors.where.not(key: config.keys).delete_all

    config.each do |key, config|
      extractor = workflow.extractors.find_by(key: key)
      extractor ||= extractor_type(config).new(workflow: workflow, key: key)
      extractor.config = config.except("min_version", "type")
      extractor.minimum_workflow_version = config["min_version"] || nil
      extractor.save!
    end
  end

  def extractor_type(config)
    case config["type"].to_s
    when "blank"
      Extractors::BlankExtractor
    when "external"
      Extractors::ExternalExtractor
    when "question"
      Extractors::QuestionExtractor
    when "survey"
      Extractors::SurveyExtractor
    when "who"
      Extractors::WhoExtractor
    when "pluck_field"
      Extractors::PluckFieldExtractor
    else
      raise "Extractor misconfigured: unknown type #{config["type"]}"
    end
  end
end
