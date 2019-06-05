require 'spec_helper'

describe Extractors::DropdownExtractor do
  def make_annotation(choice)
    {
      "task" => "T0",
      "label" => choice
    }
  end

  subject(:extractor) { described_class.new(key: "s") }

  describe '#process' do
    it 'extracts a value correctly' do
      annotations = [make_annotation("0")]
      classification = Classification.new("annotations" => annotations, "links" => {"workflow" => "1021"})

      expect(extractor.process(classification)).to eq({ "0" => 1 })
    end

    it 'combines multiple annotations for the same task' do
      annotations = [make_annotation("0"), make_annotation("0"), make_annotation("1")]
      classification = Classification.new("annotations" => annotations, "links" => {"workflow" => "1021"})

      expect(extractor.process(classification)).to eq({"0" => 2, "1" => 1})
    end

    it 'works with multiple-choice checkbox-style questions' do
      annotations = [make_annotation(["0", "1"])]
      classification = Classification.new("annotations" => annotations, "links" => {"workflow" => "1021"})

      expect(extractor.process(classification)).to eq({"0" => 1, "1" => 1})
    end

    it 'errors if annotations are missing' do
      annotations = []
      classification = Classification.new("annotations" => annotations, "links" => {"workflow" => "1021"})

      expect { extractor.process(classification) }.to raise_error(described_class::MissingAnnotation)
    end

    it 'returns nothing if annotations are missing when configured' do
      annotations = []
      classification = Classification.new("annotations" => annotations, "links" => {"workflow" => "1021"})

      extractor = described_class.new(config: {"if_missing" => "ignore"})
      expect(extractor.process(classification)).to eq({})
    end
  end

end
