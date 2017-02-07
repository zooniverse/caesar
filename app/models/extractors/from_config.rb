module Extractors
  module FromConfig
    class UnknownExtractor < StandardError; end

    def self.build(id, config)
      extractor_class(id, config["type"]).new(id, config)
    end

    def self.build_many(configs)
      return {} unless configs

      configs.map { |id, config| [id, build(id, config)] }.to_h
    end

    private

    def self.extractor_class(id, type)
      case type.to_s
      when "external"
        ExternalExtractor
      when "blank"
        BlankExtractor
      when "survey"
        SurveyExtractor
      else
        raise UnknownExtractor, "Extractor #{id} misconfigured: unknown type #{type}"
      end
    end

  end
end
