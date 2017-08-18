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
      if: [:gt, [:lookup, "s.LK", 0], [:const, 0]],
      then: [{action: :retire_subject, reason: "consensus"}]
    }
  end

  let(:workflow) do
    create :workflow, project_id: 1,
                      extractors_config: {"s" => {type: "survey", task_key: "T1"}},
                      reducers_config: {
                        "s" => {type: "stats"},
                        "g" => {type: "stats", grouping: "s.LK" }
                      },
                      rules_config: [rule]
  end

  let(:subject) { Subject.create }

  let(:pipeline) do
    workflow.classification_pipeline
  end

  let(:panoptes) { instance_double(Panoptes::Client, retire_subject: true, get_subject_classifications: {}) }

  before do
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  after do
    Action.delete_all
    Extract.delete_all
    Reduction.delete_all
    Workflow.delete_all
    Subject.delete_all
  end

  it 'retires the image', sidekiq: :inline do
    pipeline.process(classification)
    expect(panoptes).to have_received(:retire_subject).with(workflow.id, subject.id, reason: "consensus").once
  end

  it 'fetches classifications from panoptes when there are no other extracts' do
    expect { pipeline.process(classification) }.
      to change(FetchClassificationsWorker.jobs, :size).by(1)
  end

  it 'does not fetch classifications when extracts already present' do
    Extract.create(
      classification_id: classification.id,
      extractor_key: "zzz",
      subject_id: classification.subject_id,
      workflow_id: classification.workflow_id,
      classification_at: DateTime.now,
      data: {"ZZZ" => 1}
    )

    expect { pipeline.process(classification) }.
      not_to change(FetchClassificationsWorker.jobs, :size).from(0)
  end

  it 'groups extracts before reduction' do
    Subject.create! id: 2345
    Workflow.create! id: 1234, project_id: 1

    # "classroom 1" extracts for subject 2345 in workflow 1234
    Extract.create! extractor_key: 's', workflow_id: 1234, subject_id: 2345, classification_id: 11111, classification_at: DateTime.now, data: { LN: 1 }
    Extract.create! extractor_key: 's', workflow_id: 1234, subject_id: 2345, classification_id: 22222, classification_at: DateTime.now, data: { LN: 1 }
    Extract.create! extractor_key: 's', workflow_id: 1234, subject_id: 2345, classification_id: 33333, classification_at: DateTime.now, data: { TGR: 1 }
    Extract.create! extractor_key: 'g', workflow_id: 1234, subject_id: 2345, classification_id: 11111, classification_at: DateTime.now, data: { classroom: 1 }
    Extract.create! extractor_key: 'g', workflow_id: 1234, subject_id: 2345, classification_id: 22222, classification_at: DateTime.now, data: { classroom: 1 }
    Extract.create! extractor_key: 'g', workflow_id: 1234, subject_id: 2345, classification_id: 33333, classification_at: DateTime.now, data: { classroom: 1 }

    # "classroom 2" extracts for subject 2345 in workflow 1234
    Extract.create! extractor_key: 's', workflow_id: 1234, subject_id: 2345, classification_id: 44444, classification_at: DateTime.now, data: { LN: 1 }
    Extract.create! extractor_key: 's', workflow_id: 1234, subject_id: 2345, classification_id: 55555, classification_at: DateTime.now, data: { LN: 1, BR: 1 }
    Extract.create! extractor_key: 'g', workflow_id: 1234, subject_id: 2345, classification_id: 44444, classification_at: DateTime.now, data: { classroom: 2 }
    Extract.create! extractor_key: 'g', workflow_id: 1234, subject_id: 2345, classification_id: 55555, classification_at: DateTime.now, data: { classroom: 2 }

    # build a simplified pipeline to reduce these extracts
    reducer = Reducers::StatsReducer.new("s", {"group_by" => "g.classroom"})
    pipeline = described_class.new(nil, {"s" => reducer }, nil)
    pipeline.reduce(1234, 2345).map(&:serializable_hash)

    expect(Reduction.count).to eq(2)
    expect(Reduction.where(subgroup: 1).first.data).to include({"LN" => 2, "TGR" => 1})
    expect(Reduction.where(subgroup: 2).first.data).to include({"LN" => 2, "BR" => 1})
    expect(Reduction.where(subgroup: 1).first.data.keys).not_to include("classroom")
  end

end
