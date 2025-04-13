require 'json'

# app/graphql/types/json_type.rb
module Types
  class JsonType < GraphQL::Schema::Scalar
    description 'Arbitrary JSON object'

    def self.coerce_input(value, _context)
      value
    end

    def self.coerce_result(value, _context)
      value
    end
  end
end
