describe RunsReducers do
  let(:classification) do
    Classification.new(
      "id"=>"12281870",
      "created_at"=>"2016-05-16T09:34:23.682Z",
      "updated_at"=>"2016-05-16T09:34:23.750Z",
      "workflow_version"=>"332.94",
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
      "links"=>{
        "project"=>"2439",
        "user"=>"1",
        "workflow"=>workflow.id.to_s,
        "workflow_content"=>"1716",
        "subjects"=>[subject.id.to_s]
      }
    )
  end

  let(:workflow) do
    create(:workflow, project_id: 1,
                      extractors: [build(:survey_extractor, key: 's', config: {"task_key" => "T1"})]) do |w|
      create :subject_rule, workflow: w, subject_rule_effects: [build(:subject_rule_effect, config: {reason: "consensus"})]
    end
  end

  let(:reducers) do
    [
      create(:stats_reducer, key: 's', reducible: workflow),
      create(:stats_reducer, key: 'g', grouping: {"field_name" => "s.LK"}, reducible: workflow)
    ]
  end

  let(:subject) { create :subject }

  let(:panoptes) {
    instance_double(
      Panoptes::Client,
      retire_subject: true,
      workflow: {},
      project: {},
      get_subject_classifications: {"classifications" => []},
      get_user_classifications: {"classifications" => []}
    )
  }

  before do
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  it 'runs the rules in custom queue if specified' do
    reduction = create :subject_reduction, subject_id: subject.id
    reducible = create :workflow, custom_queue_name: 'custom'
    reducer = create :placeholder_reducer, reducible: reducible
    runner = described_class.new(reducible, [reducer])
    allow(reducer).to receive(:process).and_return([reduction])

    expect{
      runner.reduce(subject.id, nil, and_check_rules: true)
    }.to change{Sidekiq::Queues["custom"].size}.by(1)
  end
end
