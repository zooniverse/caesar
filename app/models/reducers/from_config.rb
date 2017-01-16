module Reducers
  module FromConfig
    class UnknownReducer < StandardError; end

    def self.build(id, config)
      case config["type"].to_s
      when "simple_survey"
        SimpleSurveyReducer.new(id, config)
      else
        raise UnknownReducer, "Reducer #{id} misconfigured: unknown type #{config["type"]}"
      end
    end

    def self.build_many(configs)
      return {} unless configs

      configs.map { |id, config| [id, build(id, config)] }.to_h
    end
  end
end
