module Reducers
  module FromConfig
    class UnknownReducer < StandardError; end

    def self.build(config)
      case config["type"].to_s
      when "simple_survey"
        SimpleSurveyReducer.new(config)
      else
        raise UnknownReducer, "Don't know reducer of type #{config["type"]}"
      end
    end

    def self.build_many(configs)
      return {} unless configs

      configs.map { |id, config| [id, build(config)] }.to_h
    end
  end
end
