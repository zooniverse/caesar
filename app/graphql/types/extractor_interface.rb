Types::ExtractorInterface = GraphQL::InterfaceType.define do
  name "Extractor"
  field :id, !types.String
end
