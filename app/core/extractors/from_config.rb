module Extractors
  module FromConfig
    def self.build(config)
      case config[:type]
      when "survey"
        SurveyExtractor.new(config)
      end
    end

    def self.build_many(configs)
      configs.map { |id, config| [id, build(config)] }.to_h
    end
  end
end
