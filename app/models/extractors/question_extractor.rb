module Extractors
  class QuestionExtractor < Extractor
    def process(classification)
      result = {}

      classification.annotations.fetch(task_key).each do |annotation|
        key = annotation.fetch("value")
        result[key] ||= 0
        result[key] += 1
      end

      result
    end

    private

    def task_key
      config["task_key"] || "T0"
    end
  end
end
