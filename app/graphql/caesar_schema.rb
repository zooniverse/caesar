require_dependency 'types/rule_type'

CaesarSchema = GraphQL::Schema.define do
  query(QueryRoot)
  mutation(MutationRoot)

  resolve_type ->(obj, ctx) {
    case obj
    when Extractors::BlankExtractor
      Types::BlankExtractorType
    when Extractors::ExternalExtractor
      Types::ExternalExtractorType
    when Extractors::QuestionExtractor
      Types::QuestionExtractorType
    when Extractors::SurveyExtractor
      Types::SurveyExtractorType
    when Extractors::WhoExtractor
      Types::WhoExtractorType
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
    when Effects::AddSubjectToCollection
      Types::AddSubjectToCollectionType
    when Effects::AddSubjectToSet
      Types::AddSubjectToSetType
    when Effects::RetireSubject
      Types::RetireSubjectType
    end
  }

  orphan_types [
    Types::BlankExtractorType,
    Types::ExternalExtractorType,
    Types::QuestionExtractorType,
    Types::SurveyExtractorType,
    Types::WhoExtractorType,

    Types::ConsensusReducerType,
    Types::CountReducerType,
    Types::ExternalReducerType,
    Types::StatsReducerType,
    Types::UniqueCountReducerType,

    Types::AddSubjectToCollectionType,
    Types::AddSubjectToSetType,
    Types::RetireSubjectType,
  ]
end
