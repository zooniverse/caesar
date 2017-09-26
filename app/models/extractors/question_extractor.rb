module Extractors
  class QuestionExtractor < Extractor
    class MissingAnnotation < StandardError; end

    config_field :task_key, default: 'T0'
    config_field :if_missing, enum: ['error', 'ignore'], default: 'error'

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
      classification.annotations.fetch(task_key)
    rescue KeyError => ex
      case if_missing
      when "error"
        raise MissingAnnotation, "No annotations for task #{task_key}"
      when "ignore"
        []
      else
        raise ex
      end
    end
  end
end
