module Extractors
  class QuestionExtractor < Extractor
    class MissingAnnotation < StandardError; end

    validates :task_key, presence: true
    validates :if_missing, presence: true, inclusion: {in: ["error", "ignore"]}

    def extract_data_for(classification)
      CountingHash.build do |result|
        fetch_annotations(classification).each do |annotation|
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

    def fetch_annotations(classification)
      case if_missing
      when "error"
        begin
          classification.annotations.fetch(task_key)
        rescue KeyError
          raise MissingAnnotation, "No annotations for task #{task_key}"
        end
      when "ignore"
        begin
          classification.annotations.fetch(task_key)
        rescue KeyError
          []
        end
      end
    end

    def task_key
      config.fetch("task_key", "T0")
    end

    def if_missing
      config["if_missing"] || "error"
    end
  end
end
