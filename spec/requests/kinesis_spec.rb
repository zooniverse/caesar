require 'rails_helper'

RSpec.describe "Kinesis stream", sidekiq: :inline do
  before do
    panoptes = instance_double(Panoptes::Client, retire_subject: true, get_subject_classifications: {"classifications" => []})
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  def http_login(username = Rails.application.secrets.kinesis["username"], password = Rails.application.secrets.kinesis["password"])
    @env ||= {}
    @env["HTTP_AUTHORIZATION"] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
    @env
  end

  it 'processes the stream events' do
    post "/kinesis",
         headers: {"CONTENT_TYPE" => "application/json"},
         params: File.read(Rails.root.join("spec/fixtures/example_kinesis_payload.json")),
         env: http_login
    expect(response.status).to eq(204)
    expect(Workflow.count).to eq(1)
    expect(Extract.count).to eq(1)
    expect(Reduction.count).to eq(1)
    expect(Effects.panoptes).to have_received(:retire_subject).once
  end

  it 'should require HTTP Basic authentication' do
    post "/kinesis",
         headers: {"CONTENT_TYPE" => "application/json"},
         params: File.read(Rails.root.join("spec/fixtures/example_kinesis_payload.json")),
         env: http_login('wrong', 'incorrect')
    expect(response.status).to eq(403)
  end
end
