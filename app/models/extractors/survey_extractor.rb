module Extractors
  class SurveyExtractor
    attr_reader :id, :task_key, :nothing_here_choice

    def initialize(id, config = {})
      @id = id
      @task_key = config["task_key"] || "T0"
      @nothing_here_choice = config["nothing_here_choice"] || "NTHNGHR"
    end

    def process(classification)
      {"choices" => choices(classification)}
    end

    private

    def choices(classification)
      values = classification.annotations.fetch(task_key)
      choices = values.flat_map { |value| value.fetch("value", []).map { |val| val["choice"] } }
      choices << nothing_here_choice if choices.empty?
      choices
    end
  end
end
