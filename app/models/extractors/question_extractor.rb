module Extractors
  class QuestionExtractor < Extractor
    def process(classification)
      { "value" => classification.annotations.fetch(task_key)[0]["value"] }
    end

    private

    def task_key
      config["task_key"] || "T0"
    end
  end
end
