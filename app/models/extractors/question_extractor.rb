module Extractors
  class QuestionExtractor < Extractor
    class MissingAnnotation < StandardError; end

    config_field :task_key, default: 'T0'
    config_field :if_missing, enum: %w[error ignore reject], default: 'error'

    def extract_data_for(classification)
      extracted_annotations = classification.annotations.fetch(task_key) do |_missing_key|
        case if_missing
        when 'error'
          raise MissingAnnotation, "No annotations for task #{task_key}"
        when 'ignore'
          []
        when 'reject'
          return Extractor::NoData # return NoData class here to avoid saving an extract in `runs_extractors` class
        else
          raise e # unknown error - ensure this is raised for visibility
        end
      end

      count_extract_answers(extracted_annotations)
    end

    private

    def count_extract_answers(annotations)
      CountingHash.build do |result|
        annotations.each do |annotation|
          value = annotation.fetch('value')
          if value.is_a?(Array)
            value.each { |key| result.increment(key) }
          else
            result.increment(value)
          end
        end
      end
    end
  end
end
