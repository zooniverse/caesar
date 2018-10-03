describe ClassificationPipeline do
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

  let(:pipeline) do
    Workflow.find(workflow.id).classification_pipeline
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

  it 'retires the image', sidekiq: :inline do
    pipeline.process(classification)
    expect(panoptes).to have_received(:retire_subject).with(workflow.id, subject.id, reason: "consensus").once
  end

  it 'fetches classifications from panoptes when there are no other extracts' do
    expect { pipeline.extract(classification) }.
      to change(FetchClassificationsWorker.jobs, :size).by(1)
  end

  it 'does not fetch subject classifications when extracts already present' do
    create(
      :extract,
      classification_id: classification.id,
      extractor_key: "zzz",
      subject_id: classification.subject_id,
      workflow_id: classification.workflow_id,
      data: {"ZZZ" => 1}
    )

    expect { pipeline.process(classification) }.
      not_to change(FetchClassificationsWorker.jobs, :size)
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
    pipeline = described_class.new(Workflow, nil, [reducer], nil, nil)
    pipeline.reduce(workflow.id, subject.id, nil)


    expect(SubjectReduction.count).to eq(2)
    expect(SubjectReduction.where(subgroup: 1).first.data).to include({"LN" => 2, "TGR" => 1})
    expect(SubjectReduction.where(subgroup: 2).first.data).to include({"LN" => 2, "BR" => 1})
  end

  it 'reduces by user instead of subject if we tell it to' do
    workflow = create(:workflow)
    subject = create(:subject)
    other_subject = create(:subject)

    create :extract, extractor_key: 's', workflow_id: workflow.id, user_id: 1234, subject_id: subject.id, classification_id: 11111, data: { LN: 1 }
    create :extract, extractor_key: 's', workflow_id: workflow.id, user_id: 1234, subject_id: other_subject.id, classification_id: 22222, data: { LN: 1 }
    create :extract, extractor_key: 's', workflow_id: workflow.id, user_id: 1235, subject_id: subject.id, classification_id: 33333, data: { TGR: 1 }
    create :extract, extractor_key: 's', workflow_id: workflow.id, user_id: 1236, subject_id: subject.id, classification_id: 44444, data: { BR: 1 }

    reducer = build(:stats_reducer, key: 's', topic: Reducer.topics[:reduce_by_user], reducible_id: workflow.id, reducible_type: "Workflow")

    pipeline = described_class.new(Workflow, nil, [reducer], nil, nil)
    pipeline.reduce(workflow.id, nil, 1234)

    expect(UserReduction.count).to eq(1)
    expect(UserReduction.first.user_id).to eq(1234)
    expect(UserReduction.first.data).to eq({"LN" => 2})
  end

  it 'calls both user rules and subject rules' do
    user_rule = instance_double( UserRule, process: true)
    subject_rule = instance_double( SubjectRule, process: true)

    workflow = create :workflow
    subject = create :subject
    user_id = 1234

    pipeline = described_class.new(Workflow, nil, nil, [subject_rule], [user_rule])
    pipeline.check_rules(workflow.id, subject.id, user_id)

    expect(user_rule).to have_received(:process).with(user_id, any_args).once
    expect(subject_rule).to have_received(:process).with(subject.id, any_args).once
  end

  it 'stops at first matching subject rule' do
    subject_rule1 = instance_double(SubjectRule, process: true)
    subject_rule2 = instance_double(SubjectRule, process: true)

    workflow = create :workflow
    subject = create :subject

    pipeline = described_class.new(Workflow, nil, nil, [subject_rule1, subject_rule2], [], :first_matching_rule)
    pipeline.check_rules(workflow.id, subject.id, nil)

    expect(subject_rule1).to have_received(:process).with(subject.id, any_args).once
    expect(subject_rule2).not_to have_received(:process)
  end

  it 'stops at first matching user rule' do
    user_rule1 = instance_double(UserRule, process: true)
    user_rule2 = instance_double(UserRule, process: true)

    workflow = create :workflow
    subject = create :subject
    user_id = 1234

    pipeline = described_class.new(Workflow, nil, nil, [], [user_rule1, user_rule2], :first_matching_rule)
    pipeline.check_rules(workflow.id, subject.id, user_id)

    expect(user_rule1).to have_received(:process).with(user_id, any_args).once
    expect(user_rule2).not_to have_received(:process)
  end

  context "reducing by project" do
    let(:project) { create :project }
    let(:reducer) { create(:stats_reducer, key: 's', reducible: project) }
    let(:subject) { create(:subject) }

    let(:pipeline) do
      described_class.new(Project, nil, [reducer], nil, nil)
    end

    it "creates reductions from project extractions" do
      create :extract, extractor_key: 's', project_id: project.id, user_id: 1234, subject_id: subject.id, classification_id: 11111, data: { LN: 1 }
      create :extract, extractor_key: 's', project_id: project.id, user_id: 1234, subject_id: subject.id, classification_id: 22222, data: { LN: 1 }

      pipeline = described_class.new(Project, nil, [reducer], nil, nil)
      expect{
        pipeline.reduce(project.id, subject.id, nil)
      }.to change{SubjectReduction.count}.by(1)
    end

    it "instantiates fetchers with correct filters" do
      filter = { project_id: project.id, subject_id: subject.id, user_id: nil }
      reduction_filter = { reducible_id: project.id, reducible_type: "Project", subject_id: subject.id, user_id: nil}

      expect(ExtractFetcher).to receive(:new).at_least(:once).with(filter).and_call_original
      expect(ReductionFetcher).to receive(:new).at_least(:once).with(reduction_filter).and_call_original

      pipeline.reduce(project.id, subject.id, nil)
    end
  end

  describe '#extract' do
    let(:blank_extractor){ instance_double(Extractors::BlankExtractor, key: 'blank', config: {task_key: 'T1'}, process: nil) }
    let(:question_extractor){ instance_double(Extractors::QuestionExtractor, key: 'question', config: {task_key: 'T1'}, process: nil) }
    let(:extractors){ [blank_extractor, question_extractor] }

    it 'calls all defined extractors' do
      allow_any_instance_of(ClassificationPipeline).to receive(:extractors).and_return(extractors)

      expect(blank_extractor).to receive(:process).once
      expect(question_extractor).to receive(:process).once

      workflow.classification_pipeline.extract(classification)
    end

    it 'calls all defined extractors even when one fails' do
      allow_any_instance_of(ClassificationPipeline).to receive(:extractors).and_return(extractors)
      allow(blank_extractor).to receive(:process).and_raise(StandardError.new('boo'))

      expect(blank_extractor).to receive(:process).once
      expect(question_extractor).to receive(:process).once

      expect do
        workflow.classification_pipeline.extract(classification)
      end.to raise_error(StandardError)
    end
  end

end
