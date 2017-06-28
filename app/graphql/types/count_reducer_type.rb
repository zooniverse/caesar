Types::CountReducerType = GraphQL::ObjectType.define do
  name "CountReducer"
  interfaces [Types::ReducerInterface]
end
