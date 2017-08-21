module Reducers
  class Reducer
    include Configurable

    attr_reader :key, :filters

    def initialize(key, config = {})
      @key = key
      @filters = config["filters"] || {}
      load_configuration(config)
    end

    def process(extracts)
      filtered_extracts = ExtractFilter.new(extracts, filters).to_a
      reduction_data_for(filtered_extracts)
    end
  end
end
