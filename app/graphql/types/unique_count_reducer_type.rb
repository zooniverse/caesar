Types::UniqueCountReducerType = GraphQL::ObjectType.define do
  name "UniqueCountReducer"
  interfaces [Types::ReducerInterface]

  field :field, types.String
end
