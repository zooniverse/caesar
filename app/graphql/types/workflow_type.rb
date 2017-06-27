

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

    resolve -> (workflow, args, ctx) {
      workflow.extracts.where(subject_id: args[:subject_id])
    }
  end

  field :reductions, types[Types::ReductionType] do
    argument :subject_id, !types.ID

    resolve -> (workflow, args, ctx) {
      workflow.reductions.where(subject_id: args[:subject_id])
    }
  end
end
