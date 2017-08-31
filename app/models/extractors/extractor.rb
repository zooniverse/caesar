module Extractors
  class Extractor
    include Configurable

    attr_reader :key, :config, :min_version

    @@NoData = Object.new
    def self.NoData
      @@NoData
    end

    def initialize(key, config = {})
      @key = key
      @min_version = config["minimum_version"] || nil
      load_configuration(config)
    end

    def process(classification)
      return Extractor.NoData if too_old?(classification)
      extract_data_for(classification)
    end

    def extract_data_for(classification)
      raise NotImplementedError
    end

    private

    def too_old?(classification)
      Gem::Version.new(min_version) > Gem::Version.new(classification.workflow_version)
    end
  end
end
