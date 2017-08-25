CaesarSchema = GraphQL::Schema.define do
  query(QueryRoot)
  mutation(MutationRoot)
end
