require 'json'

module Types
  class JsonType < GraphQL::Schema::Scalar
    description "Arbitrary JSON object"

    def self.coerce_input(value, _ctx)
      value
    end

    def self.coerce_result(value, _ctx)
      value
    end
  end
end
