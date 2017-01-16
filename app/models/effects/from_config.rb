module Effects
  module FromConfig
    class UnknownEffect < StandardError; end

    def self.build(config)
      case config["action"].to_s
      when "retire_subject"
        RetireSubject.new(config)
      else
        raise UnknownEffect, "Don't know what to do with #{config.inspect}"
      end
    end

    def self.build_many(configs)
      configs.map { |config| build(config) }
    end
  end
end
