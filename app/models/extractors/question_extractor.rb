module Extractors
  class QuestionExtractor < Extractor
    config :task_key, default: "T0"

    def extract_data_for(classification)
      CountingHash.build do |result|
        classification.annotations.fetch(task_key).each do |annotation|
          value = annotation.fetch("value")

          case value
          when Array
            value.each { |key| result.increment(key) }
          else
            result.increment(value)
          end
        end
      end
    end

    private

    def task_key
      config["task_key"]
    end
  end
end
