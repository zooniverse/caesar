# frozen_string_literal: true

require 'json'

module Types
  # Generic JSON scalar passthrough.
  class JsonType < GraphQL::Schema::Scalar
    description 'Arbitrary JSON object'

    def self.coerce_input(value, _ctx)
      value
    end

    def self.coerce_result(value, _ctx)
      value
    end
  end
end
