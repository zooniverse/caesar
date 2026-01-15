# frozen_string_literal: true

# GraphQL schema entry point connecting queries and mutations.
class CaesarSchema < GraphQL::Schema
  query(QueryRoot)
  mutation(MutationRoot)
end
