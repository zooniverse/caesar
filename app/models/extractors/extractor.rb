module Extractors
  class Extractor
    include Configurable

    attr_reader :id, :config

    def initialize(id, config = {})
      @id = id
      load_configuration(config)
    end
  end
end
