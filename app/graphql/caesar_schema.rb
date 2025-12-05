class CaesarSchema < GraphQL::Schema
  query(QueryRoot)
  mutation(MutationRoot)
end
