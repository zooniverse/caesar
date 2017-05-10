module Extractors
  class SurveyExtractor < Extractor
    config :task_key, default: "T0"
    config :nothing_here_choice, default: nil

    def process(classification)
      choices(classification)
    end

    private

    def task_key
      config["task_key"]
    end

    def nothing_here_choice
      config["nothing_here_choice"]
    end

    def choices(classification)
      choices = {}

      values = classification.annotations.fetch(task_key)
      values.each do |value|
        value.fetch("value", []).each do |val| 
          choices[val["choice"]] ||= 0
          choices[val["choice"]] += 1
        end
      end
      choices[nothing_here_choice] = 1 if choices.empty? && nothing_here_choice
      choices
    end
  end
end
