Types::BlankExtractorType = GraphQL::ObjectType.define do
  name "BlankExtractor"
  interfaces [Types::ExtractorInterface]

  field :task_key, !types.String
end
