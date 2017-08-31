module Extractors
  class WhoExtractor < Extractor
    def extract_data_for(classification)
      {'user_id' => classification.user_id}
    end
  end
end
