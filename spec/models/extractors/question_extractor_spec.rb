require 'spec_helper'

describe Extractors::QuestionExtractor do
  def make_annotation(choice)
    {
      "task" => "T0",
      "value" => choice
    }
  end

  let(:annotations) { [ make_annotation("0") ] }

  let(:classification) do
    Classification.new("annotations" => annotations, "links" => {"workflow" => "1021"})
  end

  subject(:extractor) { described_class.new("s") }

  describe '#process' do
    it 'extracts a value correctly' do
      expect(extractor.process(classification)).to eq({ "value" => "0" })
    end
  end

end
