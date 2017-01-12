require 'rails_helper'

RSpec.describe Workflow, type: :model do
  let(:workflow) { Workflow.new }

  it 'returns a list of extractors' do
    workflow.extractors_config = {
      1 => {type: "survey", task_key: "T0"}
    }
  end

  pending 'returns a list of reducers'

  describe '#rules' do
    it 'returns a rules engine' do
      workflow.rules_config = [{if: [:eq, [:const, 1], [:const, 1]],
                                then: [{action: "retire_subject"}]}]
      expect(workflow.rules).to be_a(Rules::Engine)
    end
  end
end
