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
      expect(filter.apply(extracts)).to eq([extracts[2], extracts[0], extracts[1], extracts[3], extracts[4]])
    end
  end

  describe 'combinations of filters' do
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
        results = filter.apply(extracts)
        expect(results).not_to be_empty
      end
    end

    it 'filters repeats before filtering emptyness' do
      subject = create :subject

      extracts = [
        build(:extract, subject_id: subject.id, user_id: 1, classification_at: 5.minutes.ago, data: {a: 1}),
        build(:extract, subject_id: subject.id, user_id: 1, classification_at: 2.minutes.ago, data: {}),
        build(:extract, subject_id: subject.id, user_id: 2, classification_at: 1.minutes.ago, data: {a: 1})
      ]

      filter = described_class.new(empty_extracts: "ignore_empty", repeated_classifications: "keep_last")
      expect(filter.apply(extracts)).to eq([extracts[2]])
    end
  end

  describe 'validation' do
    let(:filter){ described_class.new Hash.new }
    it 'validates an empty config' do
      expect(filter).to be_valid
    end

    it 'validates all of the filters' do
      expect_any_instance_of(Filters::FilterByTrainingBehavior).to receive(:valid?)
      expect_any_instance_of(Filters::FilterBySubrange).to receive(:valid?)
      expect_any_instance_of(Filters::FilterByExtractorKeys).to receive(:valid?)
      expect_any_instance_of(Filters::FilterByEmptiness).to receive(:valid?)
      expect_any_instance_of(Filters::FilterByRepeatedness).to receive(:valid?)
      filter.valid?
    end

    it 'fails when something is broken' do
      allow_any_instance_of(Filters::FilterByTrainingBehavior).to receive(:valid?).and_return(false)
      expect(filter).not_to be_valid
    end
  end
end
