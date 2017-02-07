module Extractors
  class BlankExtractor < Extractor
    def process(classification)
      {'blank' => blank?(classification)}
    end

    def blank?(classification)
      classification.annotations[task_key].first.present?
    end

    def task_key
      config['task_key'] || 'T0'
    end
  end
end
