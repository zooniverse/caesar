require 'spec_helper'

describe Extractors::RetrieveUserReductionExtractor do
  describe 'validation' do
    let(:workflow){ build :workflow }

    it 'requires the usual config fields' do
      expect( described_class.new(workflow: workflow) ).not_to be_valid
      expect( described_class.new(key: 's') ).not_to be_valid
    end

    it 'requires a reducer key' do
      expect( described_class.new(key: 's', workflow: workflow, config: { default_value: 'foo' } ) ).not_to be_valid
    end

    it 'requires a default value' do
      expect( described_class.new(key: 's', workflow: workflow, config: { reducer_key: 'blah' } ) ).not_to be_valid
    end

    it 'validates if everything is set' do
      expect( described_class.new(key: 's', workflow: workflow, config: { reducer_key: 'blah', default_value: 'foo' } ) ).to be_valid
    end
  end

  describe 'extraction' do
    let(:workflow){ create :workflow }

    let(:classification) do
      build :classification,
        user_id: 1234,
        workflow_id: workflow.id
    end

    let(:extractor) do
      described_class.new(
        key: 'u',
        workflow: workflow,
        config: { reducer_key: 'user_weight', default_value: { value: 0.5 }}
      )
    end

    it 'returns a user reduction if one exists' do
      create :user_reduction, user_id: 1234, reducible_type: 'Workflow', reducible_id: workflow.id, reducer_key: 'user_weight', data: { value: 4 }
      create :user_reduction, user_id: 1234, reducible_type: 'Workflow', reducible_id: workflow.id, reducer_key: 'dummy', data: { value: 3 }

      expect(extractor.process classification).to eq({ 'value' => 4 })
    end

    it 'returns the default if no user reduction exists' do
      expect(extractor.process classification).to eq({ 'value' => 0.5 })
    end

    it 'fails if there are multiple reductions' do
      create :user_reduction, user_id: 1234, reducible_type: 'Workflow', reducible_id: workflow.id, reducer_key: 'user_weight', data: { value: 3 }
      create :user_reduction, user_id: 1234, reducible_type: 'Workflow', reducible_id: workflow.id, reducer_key: 'user_weight', data: { value: 4 }, subgroup: 'blah'

      expect do
        extractor.process classification
      end.to raise_error(StandardError)
    end
  end
end