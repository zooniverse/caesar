require 'models/filters/filter_spec_helper'

describe Filters::FilterByEmptiness do
  let(:extracts){ EXTRACTS }
  let(:extract_groups) { ExtractsForClassification.from(extracts) }

  xdescribe 'validates correctly' do
    it 'can be configured to keep all' do
      filter = described_class.new(empty_extracts: "keep_all")
      expect(filter).to be_valid
    end

    it 'can be configured to ignore empty' do
      filter = described_class.new(empty_extracts: "ignore_empty")
      expect(filter).to be_valid
    end
  end

  describe 'filters correctly' do
    it 'returns all extracts when set to keep_all' do
      extracts = [
        build(:extract, data: {}),
        build(:extract, data: {a: 1})
      ]
      extract_groups = ExtractsForClassification.from(extracts)

      filter = described_class.new(empty_extracts: 'keep_all')
      result = filter.apply(extract_groups).flat_map(&:extracts)
      expect(result).to eq(extracts)
    end

    it 'returns only non-empty extracts when set to ignore_empty' do
      extracts = [
        build(:extract, data: {}),
        build(:extract, data: {a: 1})
      ]
      extract_groups = ExtractsForClassification.from(extracts)

      filter = described_class.new(empty_extracts: 'ignore_empty')
      result = filter.apply(extract_groups).flat_map(&:extracts)
      expect(result).to eq([extracts[1]])
    end
  end
end