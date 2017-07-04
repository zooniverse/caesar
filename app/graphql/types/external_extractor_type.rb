Types::ExternalExtractorType = GraphQL::ObjectType.define do
  name "ExternalExtractor"
  interfaces [Types::ExtractorInterface]

  field :url, types.String
end
