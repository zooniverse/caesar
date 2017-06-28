MutationRoot = GraphQL::ObjectType.define do
  name "MutationRoot"

  field :updateWorkflowConfig, Types::WorkflowType do
    description "Updates the workflow extractors/reducers/rules"
    argument :workflowId, !types.ID
    argument :extractorsConfig, Types::JsonType
    argument :reducersConfig, Types::JsonType
    argument :rulesConfig, Types::JsonType

    resolve ->(obj, args, ctx) {
      workflow = Workflow.accessible_by(ctx[:credential]).find(args[:workflowId])
      workflow.extractors_config = args[:extractorsConfig] if args[:extractorsConfig]
      workflow.reducers_config = args[:reducersConfig] if args[:reducersConfig]
      workflow.rules_config = args[:rulesConfig] if args[:rulesConfig]
      workflow.save!
      workflow
    }
  end

  field :upsertExtract, Types::ExtractType do
    description "Creates/updates the data for an extract"
    argument :workflowId, !types.ID
    argument :subjectId, !types.ID
    argument :classificationId, !types.ID
    argument :extractorId, !types.String
    argument :data, Types::JsonType

    resolve ->(obj, args, ctx) {
      workflow  = Workflow.accessible_by(ctx[:credential]).find(args[:workflowId])
      subject   = Subject.find(args[:subjectId])
      extractor = workflow.extractors[args[:extractorId]]
      extract   = Extract.find_or_initialize_by(workflow_id: workflow.id,
                                                extractor_id: extractor.id,
                                                classificationId: args[:classificationId],
                                                subject_id: subject.id)
      extract.update! data: args[:data]
      extract
    }
  end

  field :upsertReduction, Types::ReductionType do
    description "Creates/updates the data for an reduction"
    argument :workflowId, !types.ID
    argument :subjectId, !types.ID
    argument :reducerId, !types.String
    argument :data, Types::JsonType

    resolve ->(obj, args, ctx) {
      workflow  = Workflow.accessible_by(ctx[:credential]).find(args[:workflowId])
      subject   = Subject.find(args[:subjectId])
      reducer   = workflow.reducers[args[:reducerId]]
      reduction = Reduction.find_or_initialize_by(workflow_id: workflow.id,
                                                  reducer_id: reducer.id,
                                                  subject_id: subject.id)
      reduction.update! data: args[:data]
      reduction
    }
  end

  field :extractSubject, types.Boolean do
    description "Forces a re-evaluation of extracts (and subsequently reducers and rules) for a subject. This runs asynchronously."
    argument :workflowId, !types.ID
    argument :subjectId, !types.ID

    resolve ->(obj, args, ctx) {
      workflow  = Workflow.accessible_by(ctx[:credential]).find(args[:workflowId])
      subject   = Subject.find(args[:subjectId])

      !!FetchClassificationsWorker.perform_async(subject.id, workflow.id)
    }
  end
end
