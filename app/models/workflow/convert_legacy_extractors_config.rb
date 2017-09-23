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
      extractor ||= Extractor.of_type(config["type"]).new(workflow: workflow, key: key)
      extractor.config = config.except("minimum_version", "type")
      extractor.minimum_workflow_version = config["minimum_version"] || nil
      extractor.save!
    end
  end
end
