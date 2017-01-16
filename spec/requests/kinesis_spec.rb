require 'rails_helper'

RSpec.describe "Kinesis stream" do
  before do
    panoptes = instance_double(Panoptes::Client, retire_subject: true)
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  it 'processes the stream events' do
    post "/kinesis", File.read(Rails.root.join("spec/fixtures/example_kinesis_payload.json")), {"CONTENT_TYPE" => "application/json"}
    expect(response.status).to eq(204)
    expect(Workflow.count).to eq(1)
    expect(Extract.count).to eq(1)
    expect(Reduction.count).to eq(1)
    expect(Effects.panoptes).to have_received(:retire_subject).once
  end

  it 'should require HTTP Basic authentication'
end
