describe RunsSubjectReducers do
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

  let(:subject) { Subject.create }

  let(:runner) do
    RunsSubjectReducers.new(workflow, reducers)
  end

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

  it 'groups extracts before reduction' do
    subject = create(:subject)
    workflow = create(:workflow)

    # "classroom 1" extracts
    create :extract, extractor_key: 's', workflow_id: workflow.id, subject_id: subject.id, classification_id: 11111, data: { LN: 1 }
    create :extract, extractor_key: 's', workflow_id: workflow.id, subject_id: subject.id, classification_id: 22222, data: { LN: 1 }
    create :extract, extractor_key: 's', workflow_id: workflow.id, subject_id: subject.id, classification_id: 33333, data: { TGR: 1 }

    create :extract, extractor_key: 'g', workflow_id: workflow.id, subject_id: subject.id, classification_id: 11111, data: { classroom: 1 }
    create :extract, extractor_key: 'g', workflow_id: workflow.id, subject_id: subject.id, classification_id: 22222, data: { classroom: 1 }
    create :extract, extractor_key: 'g', workflow_id: workflow.id, subject_id: subject.id, classification_id: 33333, data: { classroom: 1 }

    # "classroom 2" extracts
    create :extract, extractor_key: 's', workflow_id: workflow.id, subject_id: subject.id, classification_id: 44444, data: { LN: 1 }
    create :extract, extractor_key: 's', workflow_id: workflow.id, subject_id: subject.id, classification_id: 55555, data: { LN: 1, BR: 1 }

    create :extract, extractor_key: 'g', workflow_id: workflow.id, subject_id: subject.id, classification_id: 44444, data: { classroom: 2 }
    create :extract, extractor_key: 'g', workflow_id: workflow.id, subject_id: subject.id, classification_id: 55555, data: { classroom: 2 }

    # build a simplified pipeline to reduce these extracts
    reducer = create(:stats_reducer, key: 's', grouping: {"field_name" => "g.classroom"}, reducible: workflow)
    runner = described_class.new(workflow, [reducer])
    runner.reduce(subject.id)


    expect(SubjectReduction.count).to eq(2)
    expect(SubjectReduction.where(subgroup: 1).first.data).to include({"LN" => 2, "TGR" => 1})
    expect(SubjectReduction.where(subgroup: 2).first.data).to include({"LN" => 2, "BR" => 1})
  end

  it 'reduces using extracts from multiple subjects when indicated by metadata' do
    workflow = create(:workflow)
    previous_subject = create(:subject)
    subject = create(:subject, metadata: { previous_subject_ids: "[#{previous_subject.id}]" })

    create :extract, id: 99999, extractor_key: 's', workflow_id: workflow.id, subject_id: previous_subject.id, classification_id: 22222, data: { TGR: 1 }
    create :extract, extractor_key: 's', workflow_id: workflow.id, subject_id: subject.id, classification_id: 11111, data: { LN: 1 }
    create :extract, extractor_key: 's', workflow_id: workflow.id, subject_id: subject.id, classification_id: 33333, data: { LN: 1 }

    reducer = create(:stats_reducer, key: 's', reducible: workflow)

    runner = described_class.new(workflow, [reducer])
    runner.reduce(subject.id)

    expect(SubjectReduction.first.data).to include({"TGR" => 1})
  end

  it 'includes relevant reductions' do
    subject = create :subject
    reducible = create :workflow
    reducer = create(:stats_reducer,
                     topic: Reducer.topics[:reduce_by_subject],
                     reducible: reducible,
                     config: {user_reducer_keys: "testing"}
                    )
    runner = described_class.new(reducible, [reducer])

    extracts = [
      create(:extract, extractor_key: 's', workflow_id: reducible.id, user_id: 1, subject_id: subject.id, data: {}),
      create(:extract, extractor_key: 's', workflow_id: reducible.id, user_id: 2, subject_id: subject.id, data: {})
    ]

    reductions = [
      create(:user_reduction, data: {skill: 15}, user_id: 1, reducible: reducible, reducer_key: 'testing'),
      create(:user_reduction, data: {skill: 22}, user_id: 2, reducible: reducible, reducer_key: 'testing')
    ]

    expect(reducer).to receive(:process).with(any_args, reductions).and_call_original
    runner.reduce(subject.id)
  end

  context "reducing by project" do
    let(:project) { create :project }
    let(:reducer) { create(:stats_reducer, key: 's', reducible: project) }
    let(:subject) { create(:subject) }

    let(:runner) do
      described_class.new(project, [reducer])
    end

    it "creates reductions from project extractions" do
      create :extract, extractor_key: 's', project_id: project.id, user_id: 1234, subject_id: subject.id, classification_id: 11111, data: { LN: 1 }
      create :extract, extractor_key: 's', project_id: project.id, user_id: 1234, subject_id: subject.id, classification_id: 22222, data: { LN: 1 }

      runner = described_class.new(project, [reducer])
      expect{
        runner.reduce(subject.id)
      }.to change{SubjectReduction.count}.by(1)
    end

    it "instantiates fetchers with correct filters" do
      filter = { project_id: project.id, subject_id: subject.id }
      reduction_filter = { reducible_id: project.id, reducible_type: "Project", subject_id: subject.id }

      expect_any_instance_of(FetchExtractsBySubject).to receive(:extracts).at_least(:once).with(filter, []).and_call_original
      expect(SubjectReductionFetcher).to receive(:new).at_least(:once).with(reduction_filter).and_call_original

      runner.reduce(subject.id)
    end
  end
end