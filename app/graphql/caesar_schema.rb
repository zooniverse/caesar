class CaesarSchema < GraphQL::Schema
  query(Types::QueryRoot)
  mutation(Types::MutationRoot)
end