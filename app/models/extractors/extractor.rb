module Extractors
  class Extractor
    include Configurable

    attr_reader :key, :config

    @@NoData = Object.new
    def self.NoData
      @@NoData
    end

    def process(classification)
      extract_data_for(classification)
    end

    def initialize(key, config = {})
      @key = key
      load_configuration(config)
    end
  end
end
