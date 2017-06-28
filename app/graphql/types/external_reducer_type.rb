Types::ExternalReducerType = GraphQL::ObjectType.define do
  name "ExternalReducer"
  interfaces [Types::ReducerInterface]

  field :url, types.String
end
