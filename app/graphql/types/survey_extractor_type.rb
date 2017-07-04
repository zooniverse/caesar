IfMissing = GraphQL::EnumType.define do
  name "IfMissing"
  description "What to do when annotation for survey task is missing"

  value("ignore", "Ignore and emit empty data hash")
  value("error", "Raise error")
  value("nothing_here", "Treat missing annotation as if the `nothing_here_choice` value was chosen.")
end

Types::SurveyExtractorType = GraphQL::ObjectType.define do
  name "SurveyExtractor"
  interfaces [Types::ExtractorInterface]

  field :task_key, !types.String
  field :nothing_here_choice, !types.String
  field :if_missing, !IfMissing
end
