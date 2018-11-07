module Filters
  class Filter
    def initialize(config)
      @config = config
    end

    def filter(_)
      raise NotImplementedError.new
    end
  end
end