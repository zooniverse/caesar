require 'models/filters/filter_spec_helper'

describe Filters::FilterByExtractorKeys do
  let(:subjects){ helper_subjects }
  let(:extracts){ helper_extracts(subjects) }
  let(:extract_groups) { ExtractsForClassification.from(extracts) }

  describe 'validates correctly' do
    it 'validates extractor_keys' do
      expect( described_class.new(extractor_keys: 'foo')).to be_valid
      expect( described_class.new(extractor_keys: ['foo'])).to be_valid
      expect( described_class.new(extractor_keys: [])).to be_valid
      expect( described_class.new(extractor_keys: 4)).not_to be_valid
      expect( described_class.new(extractor_keys: [4])).not_to be_valid
    end
  end

  describe 'filters correctly' do
    it 'returns extracts from the given extractor' do
      filter = described_class.new(extractor_keys: ['foo'])
      result = filter.apply(extract_groups).flat_map(&:extracts)
      expect(result).to eq([extracts[0], extracts[1], extracts[4]])
    end
  end
end