module Reducers
  module FromConfig
    class UnknownReducer < StandardError; end

    def self.build(id, config)
      reducer_class(id, config["type"]).new(id, config)
    end

    def self.build_many(configs)
      return {} unless configs

      configs.map { |id, config| [id, build(id, config)] }.to_h
    end

    private

    def self.reducer_class(id, type)
      case type.to_s
      when "external"
        ExternalReducer
      when "simple_survey"
        SimpleSurveyReducer
      when "simple_count"
        SimpleCountReducer
      when "unique_count"
        UniqueCountReducer
      else
        raise UnknownReducer, "Reducer #{id} misconfigured: unknown type #{type}"
      end

    end
  end
end
