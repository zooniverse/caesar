ReducerFilters = GraphQL::ObjectType.define do
  name "ReducerFilters"

  field :repeated_classifications, types.String, resolve: -> (obj, args, ctx) { obj[:repeated_classifications] }
  field :from, types.Int, resolve: -> (obj, args, ctx) { obj[:from] }
  field :to, types.Int, resolve: -> (obj, args, ctx) { obj[:to] }
  field :extractorIds, types[types.String], resolve: -> (obj, args, ctx) { obj[:extractor_ids] }
end

Types::ReducerInterface = GraphQL::InterfaceType.define do
  name "Reducer"
  field :id, !types.String
  field :filters, ReducerFilters
end
