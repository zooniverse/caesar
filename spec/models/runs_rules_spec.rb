describe RunsRules do
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
  let(:panoptes) { instance_double(Panoptes::Client, retire_subject: true) }

  before do
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  it 'calls both user rules and subject rules' do
    user_rule = instance_double( UserRule, process: true)
    subject_rule = instance_double( SubjectRule, process: true)

    workflow = create :workflow
    subject = create :subject
    user_id = 1234

    runner = described_class.new(workflow, [subject_rule], [user_rule])
    runner.check_rules(subject.id, user_id)

    expect(user_rule).to have_received(:process).with(user_id, any_args).once
    expect(subject_rule).to have_received(:process).with(subject.id, any_args).once
  end

  it 'stops at first matching subject rule' do
    subject_rule1 = instance_double(SubjectRule, process: true)
    subject_rule2 = instance_double(SubjectRule, process: true)

    workflow = create :workflow
    subject = create :subject

    runner = described_class.new(workflow, [subject_rule1, subject_rule2], [], :first_matching_rule)
    runner.check_rules(subject.id, nil)

    expect(subject_rule1).to have_received(:process).with(subject.id, any_args).once
    expect(subject_rule2).not_to have_received(:process)
  end

  it 'stops at first matching user rule' do
    user_rule1 = instance_double(UserRule, process: true)
    user_rule2 = instance_double(UserRule, process: true)

    workflow = create :workflow
    subject = create :subject
    user_id = 1234

    runner = described_class.new(workflow, [], [user_rule1, user_rule2], :first_matching_rule)
    runner.check_rules(subject.id, user_id)

    expect(user_rule1).to have_received(:process).with(user_id, any_args).once
    expect(user_rule2).not_to have_received(:process)
  end
end
