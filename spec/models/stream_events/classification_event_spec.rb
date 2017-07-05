require 'spec_helper'

describe StreamEvents::ClassificationEvent do
  let(:queue) { double(add: nil) }
  let(:stream) { double(KinesisStream, queue: queue) }
  let(:workflow) { Workflow.create! }
  let(:hash) do
    {
      "data" => ActionController::Parameters.new("links" => {"workflow" => workflow.id}),
      "linked" => {"subjects" => {}}
    }
  end

  it 'processes an event' do
    workflow.update! extractors_config: {"ext" => {type: "external"}}
    described_class.new(stream, hash).process
    expect(queue).to have_received(:add).once
  end

  it 'does not process when workflow is not in database' do
    workflow.destroy!
    described_class.new(stream, hash).process
    expect(queue).not_to have_received(:add)
  end

  it 'does not process when workflow has nothing configured' do
    workflow.update! extractors_config: nil, reducers_config: nil, rules_config: nil
    described_class.new(stream, hash).process
    expect(queue).not_to have_received(:add)
  end

  let(:data) { { "foo" => "bar" } }

  let(:sample_event){
    described_class.new(nil, {
      "data" => data,
      "linked" => {}
    })
  }

end
