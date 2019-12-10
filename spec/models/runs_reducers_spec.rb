describe RunsReducers do
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
