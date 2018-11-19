require 'spec_helper'

describe Extractors::RetrieveSubjectReductionExtractor do
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
    let(:subject) { create :subject }

    let(:classification) do
      build :classification,
        subject_id: subject.id,
        workflow_id: workflow.id
    end

    let(:extractor) do
      described_class.new(
        key: 's',
        workflow: workflow,
        config: { reducer_key: 'subject_weight', default_value: { value: 0.5 }}
      )
    end

    it 'returns a subject reduction if one exists' do
      create :subject_reduction, subject_id: subject.id, reducible_type: 'Workflow', reducible_id: workflow.id, reducer_key: 'subject_weight', data: { value: 4 }
      create :subject_reduction, subject_id: subject.id, reducible_type: 'Workflow', reducible_id: workflow.id, reducer_key: 'dummy', data: { value: 3 }

      expect(extractor.process classification).to eq({ 'value' => 4 })
    end

    it 'returns the default if no subject reduction exists' do
      expect(extractor.process classification).to eq({ 'value' => 0.5 })
    end

    it 'fails if there are multiple reductions' do
      create :subject_reduction, subject_id: subject.id, reducible_type: 'Workflow', reducible_id: workflow.id, reducer_key: 'subject_weight', data: { value: 3 }
      create :subject_reduction, subject_id: subject.id, reducible_type: 'Workflow', reducible_id: workflow.id, reducer_key: 'subject_weight', data: { value: 4 }, subgroup: 'blah'

      expect do
        extractor.process classification
      end.to raise_error(StandardError)
    end
  end
end