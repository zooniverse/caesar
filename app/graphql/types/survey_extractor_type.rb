Types::SurveyExtractorType = GraphQL::ObjectType.define do
  name "SurveyExtractor"
  interfaces [Types::ExtractorInterface]

  field :task_key, !types.String
  field :nothing_here_choice, !types.String
  field :if_missing, !types.String
end
