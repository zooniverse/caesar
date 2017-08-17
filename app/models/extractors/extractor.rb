module Extractors
  class Extractor
    include Configurable

    attr_reader :key, :config

    @@NoData = Object.new
    def self.NoData
      @@NoData
    end

    def initialize(key, config = {})
      @key = key
      load_configuration(config)
    end
  end
end
