module Reducers
  class Reducer
    attr_reader :id, :config

    def initialize(id, config = {})
      @id = id
      @config = config
    end
  end
end
