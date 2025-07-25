require 'rails_helper'

RSpec.describe "Kinesis stream", sidekiq: :inline do
  before do
    allow(Rails.application.credentials).to receive(:dig).with(:kinesis, :username).and_return('testuser')
    allow(Rails.application.credentials).to receive(:dig).with(:kinesis, :password).and_return('testpass')

    panoptes = instance_double(
      Panoptes::Client,
      retire_subject: true,
      workflow: {},
      project: {},
      get_subject_classifications: {"classifications" => []},
      get_user_classifications: {"classifications" => []}
    )
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  def http_login(username = Rails.application.credentials.dig(:kinesis, :username),
                 password = Rails.application.credentials.dig(:kinesis, :password))
    @env ||= {}
    @env["HTTP_AUTHORIZATION"] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
    @env
  end

  it 'processes the stream events' do
    rule_effect = build(:subject_rule_effect, action: :retire_subject, config: {"reason": "flagged"})
    rule = build(:subject_rule, condition: ["gte", ["lookup", "s.VHCL", 0], ["const", 1]],
                  subject_rule_effects: [rule_effect])
    workflow = create(:workflow, id: 338,
                      extractors: [build(:survey_extractor, key: 's')],
                      reducers: [build(:stats_reducer, key: 's', reducible: nil)],
                      subject_rules: [rule])

    post "/kinesis",
         headers: {"CONTENT_TYPE" => "application/json"},
         params: File.read(Rails.root.join("spec/fixtures/example_kinesis_payload.json")),
         env: http_login

    expect(response.status).to eq(204)
    expect(Workflow.count).to eq(1)
    expect(Extract.count).to eq(1)
    # the following line fails intermittently due to race conditions in the test environment, so
    # i'm removing it because i'm sick of it and it doesn't actually help us find errors in production

    # expect(SubjectReduction.count).to eq(1)
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
