module Effects
  class Effect
    attr_reader :config

    def initialize(config = {})
      @config = config
    end

    def valid?
      raise NotImplementedError
    end
  end
end
