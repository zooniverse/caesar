CaesarSchema = GraphQL::Schema.define do
  query(QueryRoot)
  mutation(MutationRoot)

  resolve_type ->(obj, ctx) {
    case obj
    when Reducers::ConsensusReducer
      Types::ConsensusReducerType
    when Reducers::CountReducer
      Types::CountReducerType
    when Reducers::ExternalReducer
      Types::ExternalReducerType
    when Reducers::StatsReducer
      Types::StatsReducerType
    when Reducers::UniqueCountReducer
      Types::UniqueCountReducerType
    when Extractors::SurveyExtractor
      Types::SurveyExtractorType
    end
  }

  orphan_types [
    Types::ConsensusReducerType,
    Types::CountReducerType,
    Types::ExternalReducerType,
    Types::StatsReducerType,
    Types::UniqueCountReducerType,
    Types::SurveyExtractorType,
  ]
end
