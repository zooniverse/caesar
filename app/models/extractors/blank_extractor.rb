module Extractors
  class BlankExtractor < Extractor
    config_field :task_key, default: 'T0'

    def extract_data_for(classification)
      {'blank' => blank?(classification)}
    end

    def blank?(classification)
      return true unless classification.annotations.present?
      return true unless classification.annotations[task_key].present?
      return true unless classification.annotations[task_key][0].present?
      return true unless classification.annotations[task_key][0]["value"].present?
      false
    end
  end
end
