Types::WorkflowType = GraphQL::ObjectType.define do
  name "Workflow"

  field :id, !types.ID
  field :created_at, !Types::TimeType, "Timestamp when this workflow was created"
  field :updated_at, !Types::TimeType, "Timestamp when this workflow was updated"

  field :extractors, types[Types::ExtractorInterface] do
    resolve ->(workflow, args, ctx) {
      workflow.extractors.values
    }
  end

  field :reducers, types[Types::ReducerInterface] do
    resolve ->(workflow, args, ctx) {
      workflow.reducers.values
    }
  end

  field :rules, types[Types::RuleType] do
    resolve ->(workflow, args, ctx) {
      workflow.rules.all
    }
  end

  field :extracts, types[Types::ExtractType] do
    argument :subject_id, !types.ID, "Filter by specific subject"
    argument :extractor_id, types.String, "Filter by specific extractor"

    resolve -> (workflow, args, ctx) {
      scope = workflow.extracts
      scope = scope.where(subject_id: args[:subject_id])
      scope = scope.where(extractor_id: args[:extractor_id]) if args[:extractor_id]
      scope
    }
  end

  field :reductions, types[Types::ReductionType] do
    argument :subject_id, !types.ID, "Filter by specific subject"

    resolve -> (workflow, args, ctx) {
      workflow.reductions.where(subject_id: args[:subject_id])
    }
  end

  field :actions, types[Types::ActionType] do
    argument :subject_id, !types.ID, "Filter by specific subject"

    resolve -> (workflow, args, ctx) {
      workflow.actions.where(subject_id: args[:subject_id])
    }
  end
end
