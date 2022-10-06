require 'spec_helper'

describe Filters::FilterByRepeatedness do
  describe 'validates correctly' do
    it 'validates keep all' do
      filter = described_class.new(repeated_classifications: "keep_all")
      expect(filter).to be_valid
    end

    it 'validates keep first' do
      filter = described_class.new(repeated_classifications: "keep_first")
      expect(filter).to be_valid
    end

    it 'validates keep last' do
      filter = described_class.new(repeated_classifications: "keep_last")
      expect(filter).to be_valid
    end

    it 'is not valid with other config values' do
      filter = described_class.new(repeated_classifications: "something")
      expect(filter).not_to be_valid
    end
  end

  describe 'filters correctly' do
    describe 'set to keep all' do
      it 'keeps all' do
        extracts = [
          Extract.new(id: 1, user_id: 1),
          Extract.new(id: 2, user_id: 1)
        ]
        extract_groups = ExtractsForClassification.from(extracts)

        filter = described_class.new(repeated_classifications: "keep_all")
        result = filter.apply(extract_groups).flat_map(&:extracts)
        expect(result).to eq([extracts[0], extracts[1]])
      end
    end

    describe 'set to keep first' do
      let(:now) { Time.now.utc }
      it 'keeps the first classification for a given user' do
        extracts = [
          Extract.new(id: 1, classification_id: 1, user_id: 1, extractor_key: 'a', classification_at: (now - 2.minute)),
          Extract.new(id: 2, classification_id: 1, user_id: 1, extractor_key: 'b', classification_at: (now - 2.minute)),
          Extract.new(id: 3, classification_id: 2, user_id: 2, extractor_key: 'a', classification_at: (now - 1.minute)),
          Extract.new(id: 4, classification_id: 2, user_id: 2, extractor_key: 'b', classification_at: (now - 1.minute)),
          Extract.new(id: 5, classification_id: 3, user_id: 1, extractor_key: 'a', classification_at: now),
          Extract.new(id: 6, classification_id: 3, user_id: 1, extractor_key: 'b', classification_at: now)
        ]
        extract_groups = ExtractsForClassification.from(extracts)
        filter = described_class.new(repeated_classifications: "keep_first")
        result = filter.apply(extract_groups).flat_map(&:extracts)
        expect(result).to match_array(extracts[0..3])
      end

      it 'keeps the first classification for a given user no matter the input order of extracts' do
        extracts = [
          Extract.new(id: 5, classification_id: 3, user_id: 1, extractor_key: 'a', classification_at: now),
          Extract.new(id: 6, classification_id: 3, user_id: 1, extractor_key: 'b', classification_at: now),
          Extract.new(id: 1, classification_id: 1, user_id: 1, extractor_key: 'a', classification_at: (now - 2.minute)),
          Extract.new(id: 2, classification_id: 1, user_id: 1, extractor_key: 'b', classification_at: (now - 2.minute)),
          Extract.new(id: 3, classification_id: 2, user_id: 2, extractor_key: 'a', classification_at: (now - 1.minute)),
          Extract.new(id: 4, classification_id: 2, user_id: 2, extractor_key: 'b', classification_at: (now - 1.minute))
        ]
        extract_groups = ExtractsForClassification.from(extracts)
        filter = described_class.new(repeated_classifications: 'keep_first')
        result = filter.apply(extract_groups).flat_map(&:extracts)
        expect(result).to match_array(extracts[2..5])
      end

      it 'keeps repeated anonymous classifications' do
        extracts = [
          Extract.new(id: 1, user_id: nil),
          Extract.new(id: 2, user_id: 2),
          Extract.new(id: 3, user_id: nil)
        ]
        extract_groups = ExtractsForClassification.from(extracts)

        filter = described_class.new(repeated_classifications: "keep_first")
        result = filter.apply(extract_groups).flat_map(&:extracts)
        expect(result).to eq(extracts)
      end

      it 'keeps the last classification for a given user' do
        extracts = [
          Extract.new(id: 1, classification_id: 1, user_id: 1, extractor_key: 'a', classification_at: (now - 2)),
          Extract.new(id: 2, classification_id: 1, user_id: 1, extractor_key: 'b', classification_at: (now - 2)),
          Extract.new(id: 3, classification_id: 2, user_id: 2, extractor_key: 'a', classification_at: (now - 1)),
          Extract.new(id: 4, classification_id: 2, user_id: 2, extractor_key: 'b', classification_at: (now - 1)),
          Extract.new(id: 5, classification_id: 3, user_id: 1, extractor_key: 'a', classification_at: now),
          Extract.new(id: 6, classification_id: 3, user_id: 1, extractor_key: 'b', classification_at: now)
        ]
        extract_groups = ExtractsForClassification.from(extracts)

        filter = described_class.new(repeated_classifications: "keep_last")
        result = filter.apply(extract_groups).flat_map(&:extracts)
        expect(result).to eq(extracts[2..5])
      end
    end
  end
end
