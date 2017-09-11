module Extractors
  class BlankExtractor < Extractor
    validates :task_key, presence: true

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

    private

    def task_key
      config.fetch('task_key', 'T0')
    end
  end
end
