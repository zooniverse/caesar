module Extractors
  module FromConfig
    class UnknownExtractor < StandardError; end

    def self.build(config)
      case config["type"].to_s
      when "survey"
        SurveyExtractor.new(config)
      else
        raise UnknownExtractor, "Don't know extractor of type #{config["type"]}, from #{config.inspect}"
      end
    end

    def self.build_many(configs)
      return {} unless configs

      configs.map { |id, config| [id, build(config)] }.to_h
    end
  end
end
