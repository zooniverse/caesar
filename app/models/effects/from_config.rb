module Effects
  module FromConfig
    class UnknownEffect < StandardError; end

    def self.build(config)
      Effects[config["action"]].new(config)
    end

    def self.build_many(configs)
      configs.map { |config| build(config) }
    end
  end
end
