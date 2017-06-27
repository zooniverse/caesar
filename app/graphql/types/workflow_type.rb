Types::WorkflowType = GraphQL::ObjectType.define do
  name "Workflow"

  field :id, !types.ID
  field :created_at, !Types::TimeType
  field :updated_at, !Types::TimeType

  field :extractors_config, Types::JsonType
  field :reducers_config, Types::JsonType
  field :rules_config, Types::JsonType

  field :extracts, types[Types::ExtractType] do
    argument :subject_id, !types.ID
    argument :extractor_id, types.String

    resolve -> (workflow, args, ctx) {
      scope = workflow.extracts
      scope = scope.where(subject_id: args[:subject_id])
      scope = scope.where(extractor_id: args[:extractor_id]) if args[:extractor_id]
      scope
    }
  end

  field :reductions, types[Types::ReductionType] do
    argument :subject_id, !types.ID

    resolve -> (workflow, args, ctx) {
      workflow.reductions.where(subject_id: args[:subject_id])
    }
  end

  field :actions, types[Types::ActionType] do
    argument :subject_id, !types.ID

    resolve -> (workflow, args, ctx) {
      workflow.actions.where(subject_id: args[:subject_id])
    }
  end
end
