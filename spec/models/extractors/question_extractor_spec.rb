require 'spec_helper'

describe Extractors::QuestionExtractor do
  def make_annotation(choice)
    {
      "task" => "T0",
      "value" => choice
    }
  end

  subject(:extractor) { described_class.new("s") }

  describe '#process' do
    it 'extracts a value correctly' do
      annotations = [make_annotation("0")]
      classification = Classification.new("annotations" => annotations, "links" => {"workflow" => "1021"})

      expect(extractor.process(classification)).to eq({ "0" => 1 })
    end

    it 'extracts multiple answers' do
      annotations = [make_annotation("0"), make_annotation("0"), make_annotation("1")]
      classification = Classification.new("annotations" => annotations, "links" => {"workflow" => "1021"})

      expect(extractor.process(classification)).to eq({"0" => 2, "1" => 1})
    end
  end

end
