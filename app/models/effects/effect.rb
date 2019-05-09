module Effects
  class Effect
    def config=(new_config)
      @config = new_config
    end

    def config
      @config.with_indifferent_access
    end

    def initialize(config = {})
      @config = config
    end

    def valid?
      raise NotImplementedError
    end
  end
end
