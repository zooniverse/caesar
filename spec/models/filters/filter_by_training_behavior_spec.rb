require 'models/filters/filter_spec_helper'

describe Filters::FilterByTrainingBehavior do
  let(:subjects){ helper_subjects }
  let(:extracts){ helper_extracts(subjects) }
  let(:extract_groups) { ExtractsForClassification.from(extracts) }

  describe 'validation' do
    it 'validates training_behavior' do
      expect(subjects.length).to eq(2)
      expect(described_class.new(training_behavior: 'ignore_training')).to be_valid
      expect(described_class.new(training_behavior: 'training_only')).to be_valid
      expect(described_class.new(training_behavior: 'experiment_only')).to be_valid
      expect(described_class.new(training_behavior: 'dfjksjfdkljfskl')).not_to be_valid
    end
  end

  describe 'filters' do
    it 'does nothing if we tell it to' do
      filter = described_class.new training_behavior: 'ignore_training'
      result = filter.apply(extract_groups).flat_map(&:extracts)
      expect(result).to eq(extracts)
    end

    it 'can pull out training subjects' do
      filter = described_class.new training_behavior: 'training_only'
      result = filter.apply(extract_groups).flat_map(&:extracts)
      expect(result).to eq(extracts[2..3])
    end

    it 'can pull out experimental subjects' do
      filter = described_class.new training_behavior: 'training_only'
      result = filter.apply(extract_groups).flat_map(&:extracts)
      expect(result).to eq(extracts.slice(2..3))
    end
  end
end