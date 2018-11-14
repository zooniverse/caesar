require 'models/filters/filter_spec_helper'

describe Filters::FilterBySubrange do
  let(:extracts){ EXTRACTS }
  let(:extract_groups) { ExtractsForClassification.from(extracts) }

  xdescribe 'validates correctly' do
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