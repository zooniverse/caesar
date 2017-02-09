module Reducers
  class Reducer
    attr_reader :id, :config

    def initialize(id, config = {})
      @id = id
      @config = config
    end

    def process(extracts)
      filtered_extracts = ExtractFilter.new(extracts, filters).to_a
      reduction_data_for(filtered_extracts)
    end

    private

    def filters
      config["filters"] || {}
    end
  end
end
