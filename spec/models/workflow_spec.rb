require 'rails_helper'

RSpec.describe Workflow, type: :model do
  let(:workflow) { Workflow.new }

  it 'returns a list of extractors' do
    workflow.extractors_config = {
      "s" => {type: "survey", task_key: "T0"}
    }

    expect(workflow.extractors.size).to eq(1)
    expect(workflow.extractors['s']).to be_a(Extractors::SurveyExtractor)
  end

  it 'returns a list of reducers' do
    workflow.reducers_config = {
      "s" => {type: "stats"}
    }

    expect(workflow.reducers.size).to eq(1)
    expect(workflow.reducers['s']).to be_a(Reducers::StatsReducer)
  end
end
