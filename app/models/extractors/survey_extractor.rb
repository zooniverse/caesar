module Extractors
  class SurveyExtractor < Extractor
    class MissingAnnotation < StandardError; end

    config :task_key, default: "T0"
    config :nothing_here_choice, default: nil
    config :if_missing, default: "error"

    def process(classification)
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

    def task_key
      config["task_key"]
    end

    def nothing_here_choice
      config["nothing_here_choice"]
    end

    def if_missing
      config["if_missing"]
    end

    def fetch_values(classification)
      case if_missing
      when "ignore"
        []
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
