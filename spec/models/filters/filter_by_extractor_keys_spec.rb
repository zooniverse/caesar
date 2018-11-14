require 'models/filters/filter_spec_helper'

describe Filters::FilterByExtractorKeys do
  let(:extracts){ EXTRACTS }
  let(:extract_groups) { ExtractsForClassification.from(extracts) }

  xdescribe 'validates correctly' do
  end

  describe 'filters correctly' do
    it 'returns extracts from the given extractor' do
      filter = described_class.new(extractor_keys: ['foo'])
      result = filter.apply(extract_groups).flat_map(&:extracts)
      expect(result).to eq([extracts[0], extracts[1], extracts[4]])
    end
  end
end