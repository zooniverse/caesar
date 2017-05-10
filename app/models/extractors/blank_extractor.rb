module Extractors
  class BlankExtractor < Extractor
    config :task_key, default: "T0"

    def process(classification)
      {'blank' => blank?(classification)}
    end

    def blank?(classification)
      return true unless classification.annotations.present?
      return true unless classification.annotations[task_key].present?
      return true unless classification.annotations[task_key][0].present?
      return true unless classification.annotations[task_key][0]["value"].present?
      false
    end

    def task_key
      config['task_key']
    end
  end
end
