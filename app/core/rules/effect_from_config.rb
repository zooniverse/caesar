module Rules
  module EffectFromConfig
    def self.build(config)

    end

    def self.build_many(configs)
      configs.map { |config| build(config) }
    end
  end
end
