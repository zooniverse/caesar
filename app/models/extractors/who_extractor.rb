module Extractors
  class WhoExtractor < Extractor
    def process(classification)
      {'user_id' => classification.user_id}
    end
  end
end
