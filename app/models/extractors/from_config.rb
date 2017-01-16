module Extractors
  module FromConfig
    class UnknownExtractor < StandardError; end

    def self.build(id, config)
      case config["type"].to_s
      when "survey"
        SurveyExtractor.new(id, config)
      else
        raise UnknownExtractor, "Extractor #{id} misconfigured: unknown type #{config["type"]}"
      end
    end

    def self.build_many(configs)
      return {} unless configs

      configs.map { |id, config| [id, build(id, config)] }.to_h
    end
  end
end
