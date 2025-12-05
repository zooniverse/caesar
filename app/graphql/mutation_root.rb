class MutationRoot < GraphQL::Schema::Object
  graphql_name "MutationRoot"

  field :create_data_request, Types::DataRequestType, null: true do
    description <<-END.strip_heredoc
      Creates a new DataRequest with the specified filters. Poll for new state and
      when marked COMPLETE, the url property will have a link to the downloadable
      export file.
    END

    argument :exportable_id, ID, required: true
    argument :exportable_type, ID, required: true
    argument :requested_data, Types::RequestedDataEnum, required: true
    argument :subgroup, String, required: false
    argument :user_id, Integer, required: false
  end

  def create_data_request(exportable_id:, exportable_type:, requested_data:, subgroup: nil, user_id: nil)
    CreatesDataRequests.call(
      object,
      {
        exportable_id: exportable_id,
        exportable_type: exportable_type,
        requested_data: requested_data,
        subgroup: subgroup,
        user_id: user_id
      }.with_indifferent_access,
      context
    )
  end

  field :upsert_extract, Types::ExtractType, null: true do
    description <<-END.strip_heredoc
      Creates/updates the data for an extract. Triggers evaluation of reductions and then
      rules afterwards (asynchronously).
    END

    argument :workflow_id, ID, required: true
    argument :subject_id, ID, required: true
    argument :classification_id, ID, required: true
    argument :extractor_key, String, required: true
    argument :data, Types::JsonType, required: false
  end

  def upsert_extract(workflow_id:, subject_id:, classification_id:, extractor_key:, data: nil)
    workflow = Workflow.accessible_by(context[:credential]).find(workflow_id)
    subject = Subject.find(subject_id)
    extractor = workflow.extractors[extractor_key]
    extract = Extract.find_or_initialize_by(
      workflow_id: workflow.id,
      extractor_id: extractor.id,
      classification_id: classification_id,
      subject_id: subject.id
    )
    extract.update!(data: data)
    extract
  end

  field :upsert_reduction, Types::SubjectReductionType, null: true do
    description <<-END.strip_heredoc
      Creates/updates the data for a reduction. Triggers evaluation of the workflow rules
      afterwards (asynchronously).
    END

    argument :workflow_id, ID, required: true
    argument :subject_id, ID, required: true
    argument :reducer_key, String, required: true
    argument :data, Types::JsonType, required: false
  end

  def upsert_reduction(workflow_id:, subject_id:, reducer_key:, data: nil)
    workflow = Workflow.accessible_by(context[:credential]).find(workflow_id)
    subject = Subject.find(subject_id)
    reducer = workflow.reducers[reducer_key]
    reduction = SubjectReduction.find_or_initialize_by(
      workflow_id: workflow.id,
      reducer_id: reducer.id,
      subject_id: subject.id
    )
    reduction.update!(data: data)
    reduction
  end

  field :extract_subject, Boolean, null: true do
    description <<-END.strip_heredoc
      Forces a re-evaluation of extracts (and subsequently reducers and rules) for a subject.
      This works by fetching a complete list of classifications for the specified subject,
      and then extracting, reducing and applying the rules on it. This means that any data
      inconsistencies should get cleared up by running this, and that it should be idempotent.

      This runs asynchronously. Returns true if a job was enqueued. Returns false if no job
      was enqueued, typically this happens when one was already pending.
    END

    argument :workflow_id, ID, required: true
    argument :subject_id, ID, required: true
  end

  def extract_subject(workflow_id:, subject_id:)
    workflow = Workflow.accessible_by(context[:credential]).find(workflow_id)
    subject = Subject.find(subject_id)

    !!FetchClassificationsWorker.perform_async(workflow.id, subject.id, FetchClassificationsWorker.fetch_for_subject)
  end
end
