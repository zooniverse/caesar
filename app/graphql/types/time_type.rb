module Types
  class TimeType < GraphQL::Schema::Scalar
    description 'Time since epoch in seconds (aka UNIX timestamp).'

    def self.coerce_input(value, _context)
      Time.at(Float(value))
    end

    def self.coerce_result(value, _context)
      value.to_f
    end
  end
end
