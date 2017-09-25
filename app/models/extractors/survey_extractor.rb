module Extractors
  class SurveyExtractor < Extractor
    class MissingAnnotation < StandardError; end

    config_field :task_key, default: 'T0'
    config_field :if_missing, enum: ['error', 'ignore', 'nothing_here'], default: 'error'
    config_field :nothing_here_choice, default: nil

    def extract_data_for(classification)
      choices = {}

      values = fetch_values(classification)
      values.each do |value|
        value.fetch("value", []).each do |val|
          choices[val["choice"]] ||= 0
          choices[val["choice"]] += 1
        end
      end

      choices[nothing_here_choice] = 1 if choices.empty? && nothing_here_choice

      choices
    end

    private

    def fetch_values(classification)
      case if_missing
      when "ignore"
        begin
          classification.annotations.fetch(task_key)
        rescue KeyError
          []
        end
      when "nothing_here"
        [{"value" => [{"choice" => nothing_here_choice}]}]
      else
        begin
          classification.annotations.fetch(task_key)
        rescue KeyError
          raise MissingAnnotation, "No annotations for task #{task_key}"
        end
      end
    end
  end
end
