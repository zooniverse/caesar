describe ClassificationPipeline do

  let(:reducers) do
    [
      build(:stats_reducer, key: 's'),
      build(:stats_reducer, key: 'g', grouping: "s.LK")
    ]
  end

  let(:workflow) do
    create(:workflow, project_id: 1,
                      extractors: [build(:survey_extractor, key: 's', config: {"task_key" => "T0"})],
                      reducers: reducers) do |w|
      create :subject_rule, workflow: w, subject_rule_effects: [build(:subject_rule_effect, config: {reason: "consensus"})]
    end
  end

  let(:subject) { create :subject }
  let(:classification) { create :classification, :survey_task, workflow: workflow, subject: subject }

  let(:pipeline) do
    Workflow.find(workflow.id).classification_pipeline
  end

  let(:panoptes) {
    instance_double(
      Panoptes::Client,
      retire_subject: true,
      get_subject_classifications: {},
      get_user_classifications: {}
    )
  }

  before do
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  it 'retires the image', sidekiq: :inline do
    pipeline.process(classification)
    expect(panoptes).to have_received(:retire_subject).with(workflow.id, subject.id, reason: "consensus").once
  end

  it 'calls both user rules and subject rules' do
    user_rule = instance_double( UserRule, process: true)
    subject_rule = instance_double( SubjectRule, process: true)

    workflow = create :workflow
    subject = create :subject
    user_id = 1234

    pipeline = described_class.new(nil, nil, [subject_rule], [user_rule])
    pipeline.check_rules(workflow.id, subject.id, user_id)

    expect(user_rule).to have_received(:process).with(user_id, any_args).once
    expect(subject_rule).to have_received(:process).with(subject.id, any_args).once
  end
end
