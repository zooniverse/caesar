require 'spec_helper'

describe ExtractFilter do
  let(:extracts) {
    [
      Extract.new(
        id: 0,
        extractor_key: "foo",
        classification_id: 1234,
        classification_at: Date.new(2014, 12, 4),
        data: {"foo" => "bar"}
      ),
      Extract.new(
        id: 1,
        extractor_key: "foo",
        classification_id: 1234,
        classification_at: Date.new(2014, 12, 4),
        data: {"foo" => "baz"}
      ),
      Extract.new(
        id: 2,
        extractor_key: "bar",
        classification_id: 1235,
        classification_at: Date.new(1980, 10, 22),
        data: {"bar" => "baz"}
      ),
      Extract.new(
        id: 3,
        extractor_key: "baz",
        classification_id: 1236,
        classification_at: Date.new(2017, 2, 7),
        data: {"baz" => "bar"}
      ),
      Extract.new(
        id: 4,
        extractor_key: "foo",
        classification_id: 1237,
        classification_at: Date.new(2017, 2, 7),
        data: {"foo" => "fufufu"}
      )
    ]
  }

  describe 'with no filters' do
    let(:filter) { ExtractFilter.new({}) }

    it 'returns the unfiltered list of extracts, sorted by classification_at' do
      expect(filter.filter(extracts)).to eq([extracts[2], extracts[0], extracts[1], extracts[3], extracts[4]])
    end
  end

  describe 'extractor AND subrange filtering' do
    it 'filters by extractor first' do
      extracts = [
        build(:extract, extractor_key: 'foo', classification_at: Date.new(2017, 9, 1), data: {}),
        build(:extract, extractor_key: 'foo', classification_at: Date.new(2017, 9, 2), data: {}),
        build(:extract, extractor_key: 'bar', classification_at: Date.new(2017, 9, 3), data: {}),
      ]

      # if we filtered by subrange/index before extractor key, then we would discard the only
      # extract produced by the 'bar' extractor
      filter = described_class.new(from: 0, to: 0, extractor_keys: ["bar"])
      expect(filter.filter(extracts)).not_to be_empty
    end
  end

  describe 'subrange filtering' do
    it 'returns extracts starting from a given index' do
      filter = described_class.new(from: 2)
      expect(filter.filter(extracts)).to eq([extracts[3], extracts[4]])
    end

    it 'returns extracts up to a given index' do
      filter = described_class.new(to: 1)
      expect(filter.filter(extracts)).to eq([extracts[2], extracts[0], extracts[1]])
    end

    it 'returns extracts except the last N' do
      filter = described_class.new(to: -2)
      expect(filter.filter(extracts)).to eq([extracts[2], extracts[0], extracts[1], extracts[3]])
    end

    it 'returns extracts in a slice' do
      filter = described_class.new(from: 1, to: 2)
      expect(filter.filter(extracts)).to eq([extracts[0], extracts[1], extracts[3]])
    end
  end

  describe 'extractor filtering' do
    it 'returns extracts from the given extractor' do
      filter = described_class.new(extractor_keys: ["foo"])
      expect(filter.filter(extracts)).to eq([extracts[0], extracts[1], extracts[4]])
    end
  end

  describe 'empty filtering' do
    it 'returns all extracts when set to keep_all' do
      extracts = [
        build(:extract, data: {}),
        build(:extract, data: {a: 1})
      ]

      filter = described_class.new(empty_extracts: "keep_all")
      expect(filter).to be_valid
      expect(filter.filter(extracts)).to eq(extracts)
    end

    it 'returns only non-empty extracts when set to ignore_empty' do
      extracts = [
        build(:extract, data: {}),
        build(:extract, data: {a: 1})
      ]

      filter = described_class.new(empty_extracts: "ignore_empty")
      expect(filter).to be_valid
      expect(filter.filter(extracts)).to eq([extracts[1]])
    end

    it 'filters repeats before filtering emptyness' do
      extracts = [
        build(:extract, user_id: 1, classification_at: 5.minutes.ago, data: {a: 1}),
        build(:extract, user_id: 1, classification_at: 2.minutes.ago, data: {}),
        build(:extract, user_id: 2, classification_at: 1.minutes.ago, data: {a: 1})
      ]

      filter = described_class.new(empty_extracts: "ignore_empty", repeated_classifications: "keep_last")
      expect(filter).to be_valid
      expect(filter.filter(extracts)).to eq([extracts[2]])
    end
  end

  describe 'repeats filtering' do
    describe 'set to keep all' do
      it 'keeps all' do
        extracts = [
          Extract.new(id: 1, user_id: 1),
          Extract.new(id: 2, user_id: 1)
        ]

        filter = described_class.new(repeated_classifications: "keep_all")
        expect(filter).to be_valid
        expect(filter.filter(extracts)).to eq([extracts[0], extracts[1]])
      end
    end

    describe 'set to keep first' do
      it 'keeps the first classification for a given user' do
        extracts = [
          Extract.new(id: 1, classification_id: 1, user_id: 1, extractor_key: "a"),
          Extract.new(id: 2, classification_id: 1, user_id: 1, extractor_key: "b"),
          Extract.new(id: 3, classification_id: 2, user_id: 2, extractor_key: "a"),
          Extract.new(id: 4, classification_id: 2, user_id: 2, extractor_key: "b"),
          Extract.new(id: 5, classification_id: 3, user_id: 1, extractor_key: "a"),
          Extract.new(id: 6, classification_id: 3, user_id: 1, extractor_key: "b")
        ]

        filter = described_class.new(repeated_classifications: "keep_first")
        expect(filter.filter(extracts)).to eq(extracts[0..3])
      end

      it 'keeps repeated anonymous classifications' do
        extracts = [
          Extract.new(id: 1, user_id: nil),
          Extract.new(id: 2, user_id: 2),
          Extract.new(id: 3, user_id: nil)
        ]

        filter = described_class.new(repeated_classifications: "keep_first")
        expect(filter).to be_valid
        expect(filter.filter(extracts)).to eq(extracts)
      end
    end

    describe 'set to keep last' do
      it 'keeps the last classification for a given user' do
        extracts = [
          Extract.new(id: 1, classification_id: 1, user_id: 1, extractor_key: "a"),
          Extract.new(id: 2, classification_id: 1, user_id: 1, extractor_key: "b"),
          Extract.new(id: 3, classification_id: 2, user_id: 2, extractor_key: "a"),
          Extract.new(id: 4, classification_id: 2, user_id: 2, extractor_key: "b"),
          Extract.new(id: 5, classification_id: 3, user_id: 1, extractor_key: "a"),
          Extract.new(id: 6, classification_id: 3, user_id: 1, extractor_key: "b")
        ]

        filter = described_class.new(repeated_classifications: "keep_last")
        expect(filter).to be_valid
        expect(filter.filter(extracts)).to eq(extracts[2..5])
      end

      it 'keeps repeated anonymous classifications' do
        extracts = [
          Extract.new(id: 1, user_id: nil),
          Extract.new(id: 2, user_id: 2),
          Extract.new(id: 3, user_id: nil)
        ]

        filter = described_class.new(repeated_classifications: "keep_first")
        expect(filter).to be_valid
        expect(filter.filter(extracts)).to eq(extracts)
      end

      it 'is not valid with other config values' do
        filter = described_class.new(repeated_classifications: "something")
        expect(filter).not_to be_valid
      end
    end
  end
end
