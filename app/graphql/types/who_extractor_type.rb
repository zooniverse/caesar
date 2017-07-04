Types::WhoExtractorType = GraphQL::ObjectType.define do
  name "WhoExtractor"
  interfaces [Types::ExtractorInterface]

  field :task_key, !types.String
end
