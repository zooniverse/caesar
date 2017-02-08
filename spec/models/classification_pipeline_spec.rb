describe ClassificationPipeline do
  let(:classification) do
    Classification.new(
      "id"=>"12281870",
      "created_at"=>"2016-05-16T09:34:23.682Z",
      "updated_at"=>"2016-05-16T09:34:23.750Z",
      "user_ip"=>"1.2.3.4",
      "workflow_version"=>"332.94",
      "gold_standard"=>nil,
      "expert_classifier"=>nil,
      "annotations"=>[
        {
          "task"=>"T1",
          "value"=>[
            {"choice"=>"LK", "answers"=>{"BHVR"=>["RSTNG"], "DLTS"=>"1", "CLLRPRSNT"=>"S"}, "filters"=>{}}
          ]
        }
      ],
      "metadata"=>{
        "session"=>"8911f478cc88fba60af9e9960531aea7bf5c724cc17970dd64ee129f1881f5e6",
        "viewport"=>{"width"=>1360, "height"=>653},
        "started_at"=>"2016-05-16T09:33:40.181Z",
        "user_agent"=>"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36",
        "utc_offset"=>"-10800",
        "finished_at"=>"2016-05-16T09:34:23.243Z",
        "live_project"=>true,
        "user_language"=>"en",
        "user_group_ids"=>[],
        "subject_dimensions"=>[
          {"clientWidth"=>732, "clientHeight"=>549, "naturalWidth"=>800, "naturalHeight"=>600},
          {"clientWidth"=>732, "clientHeight"=>549, "naturalWidth"=>800, "naturalHeight"=>600},
          {"clientWidth"=>732, "clientHeight"=>549, "naturalWidth"=>800, "naturalHeight"=>600}
        ],
        "workflow_version"=>"332.94"
      },
      "href"=>"/classifications/12281870",
      "links"=>{
        "project"=>"2439",
        "user"=>"1",
        "workflow"=>workflow.id.to_s,
        "workflow_content"=>"1716",
        "subjects"=>[subject.id.to_s]
      }
    )
  end

  let(:rule) do
    {
      if: [:gt, [:lookup, "survey-total-LK"], [:const, 0]],
      then: [{action: :retire_subject, reason: "consensus"}]
    }
  end

  let(:workflow) do
    Workflow.create extractors_config: {"s" => {type: "survey", task_key: "T1"}},
                    reducers_config: {"s" => {type: "simple_survey"}},
                    rules_config: [rule]
  end

  let(:subject) { Subject.create }

  let(:pipeline) do
    workflow.classification_pipeline
  end

  it 'retires the image' do
    panoptes = instance_double(Panoptes::Client, retire_subject: true)
    allow(Effects).to receive(:panoptes).and_return(panoptes)

    pipeline.process(classification)
    expect(panoptes).to have_received(:retire_subject).with(workflow.id, subject.id, reason: "consensus").once
  end

  it 'fetches classifications from panoptes when there are no other extracts' do
    expect do
      pipeline.process(classification)
    end.to change(FetchClassificationsWorker.jobs, :size).by(1)
  end

  it 'does not fetch classifications when extracts already present' do
    Extract.create(
      extractor_id: "zzz",
      subject_id: classification.subject_id,
      workflow_id: classification.workflow_id,
      classification_at: DateTime.now,
      data: { "choices" => ["ZZZ"] }
    )

    expect do
      pipeline.process(classification)
    end.not_to change(FetchClassificationsWorker.jobs, :size).from(0)
  end
end
