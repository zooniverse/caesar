module Extractors
  class Extractor
    include Configurable

    attr_reader :key, :config

    def initialize(key, config = {})
      @key = key
      load_configuration(config)
    end
  end
end
