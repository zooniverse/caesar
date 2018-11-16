require 'models/filters/filter_spec_helper'

describe Filters::FilterBySubrange do
  let(:subjects){ helper_subjects }
  let(:extracts){ helper_extracts(subjects) }
  let(:extract_groups) { ExtractsForClassification.from(extracts) }

  describe 'validates correctly' do
    it 'validates the from field' do
      expect(described_class.new({})).to be_valid
      expect(described_class.new(from: 5)).to be_valid
      expect(described_class.new(from: '5')).to be_valid
      expect(described_class.new(from: 'aaaa')).not_to be_valid
    end

    it 'validates the to field' do
      expect(described_class.new({})).to be_valid
      expect(described_class.new(to: 5)).to be_valid
      expect(described_class.new(to: '5')).to be_valid
      expect(described_class.new(to: 'aaaa')).not_to be_valid
    end
  end

  describe 'filters extract_groups by subrange' do
    it 'returns extracts starting from a given index' do
      filter = described_class.new(from: 2)
      result = filter.apply(extract_groups).flat_map(&:extracts)
      expect(result).to eq([extracts[3], extracts[4]])
    end

    it 'returns extracts up to a given index' do
      filter = described_class.new(to: 1)
      result = filter.apply(extract_groups).flat_map(&:extracts)
      expect(result).to eq([extracts[2], extracts[0], extracts[1]])
    end

    it 'returns extracts except the last N' do
      filter = described_class.new(to: -2)
      result = filter.apply(extract_groups).flat_map(&:extracts)
      expect(result).to eq([extracts[2], extracts[0], extracts[1], extracts[3]])
    end

    it 'returns extracts in a slice' do
      filter = described_class.new(from: 1, to: 2)
      result = filter.apply(extract_groups).flat_map(&:extracts)
      expect(result).to eq([extracts[0], extracts[1], extracts[3]])
    end
  end
end