Types::QuestionExtractorType = GraphQL::ObjectType.define do
  name "QuestionExtractor"
  interfaces [Types::ExtractorInterface]

  field :task_key, !types.String
end
