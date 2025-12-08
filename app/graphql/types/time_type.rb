# frozen_string_literal: true

module Types
  # Scalar representing UNIX timestamps.
  class TimeType < GraphQL::Schema::Scalar
    description 'Time since epoch in seconds (aka UNIX timestamp).'

    def self.coerce_input(value, _ctx)
      Time.at(Float(value))
    end

    def self.coerce_result(value, _ctx)
      value.to_f
    end
  end
end
