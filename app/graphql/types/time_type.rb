Types::TimeType = GraphQL::ScalarType.define do
  name "Time"
  description "Time since epoch in seconds (aka UNIX timestamp)."

  coerce_input ->(value, ctx) { Time.at(Float(value)) }
  coerce_result ->(value, ctx) { value.to_f }
end
