MutationRoot = GraphQL::ObjectType.define do
  name "MutationRoot"

  field :createDataRequest, DataRequest::Type do
    description <<-END.strip_heredoc
      Creates a new DataRequest with the specified filters. Poll for new state and
      when marked COMPLETE, the url property will have a link to the downloadable
      export file.
    END

    argument :workflowId, !types.ID
    argument :requestedData, DataRequest::RequestedData
    argument :subgroup, types.String
    argument :userId, types.Int

    resolve ->(obj, args, ctx) {
      workflow = Workflow.accessible_by(ctx[:credential]).find(args[:workflowId])
      data_request = workflow.data_requests.build(
        user_id: args[:userId],
        subgroup: args[:subgroup],
        requested_data: args[:requestedData]
      )

      data_request.status = DataRequest.statuses[:pending]
      data_request.url = nil
      data_request.save!

      DataRequestWorker.perform_async(data_request.workflow_id)
      data_request
    }
  end

  field :upsertExtract, Extract::Type do
    description <<-END.strip_heredoc
      Creates/updates the data for an reduction. Triggers evaluation of reductions and then
      rules afterwards (asynchronously).
    END

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

  field :upsertReduction, Reduction::Type do
    description <<-END.strip_heredoc
      Creates/updates the data for an reduction. Triggers evaluation of the workflow rules
      afterwards (asynchronously).
    END

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
    description <<-END.strip_heredoc
      Forces a re-evaluation of extracts (and subsequently reducers and rules) for a subject.
      This works by fetching a complete list of classifications for the specified subject,
      and then extracting, reducing and applying the rules on it. This means that any data
      inconsistencies should get cleared up by running this, and that it should be idempotent.

      This runs asynchronously. Returns true if a job was enqueued. Returns false if no job
      was enqueued, typically this happens when one was already pending.
    END

    argument :workflowId, !types.ID
    argument :subjectId, !types.ID

    resolve ->(obj, args, ctx) {
      workflow  = Workflow.accessible_by(ctx[:credential]).find(args[:workflowId])
      subject   = Subject.find(args[:subjectId])

      !!FetchClassificationsWorker.perform_async(subject.id, workflow.id)
    }
  end
end
