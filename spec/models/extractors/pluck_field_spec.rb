require 'spec_helper'

describe Extractors::PluckFieldExtractor do
  let(:classification) do
    Classification.new(
      "annotations" => [{ "some_key": "some_value" }],
      "metadata" => [{ "shutter_speed" => ["1/8", "1/4"] }],
      "user_id" => 1234,
      "links" => {"workflow" => "1021"}
    )
  end

  describe '#process' do
    it 'requires path and name to be set' do
      expect{ described_class.new("s") }.to raise_error(ArgumentError)
      expect{ described_class.new("s", "path" => "p") }.to raise_error(ArgumentError)
      expect{ described_class.new("s", "name" => "n") }.to raise_error(ArgumentError)
      expect{ described_class.new("s", {"name" => "p", "path" => "n"}) }.not_to raise_error()
    end

    it 'processes a classification' do
      simple = described_class.new("s", {"name" => "whodunit", "path" => "$.user_id"})
      result = simple.process(classification)

      expect(result.blank?).to be(false)
      expect(result).to be_a(Hash)
      expect(result["whodunit"]).to eq(1234)

      complex = described_class.new("c", {"name" => "how_fast", "path" => "$.metadata[0].shutter_speed"})
      result = complex.process(classification)

      expect(result.blank?).to be(false)
      expect(result).to be_a(Hash)
      expect(result["how_fast"]).to be_a(Array)
      expect(result["how_fast"]).to eq(["1/8", "1/4"])
    end

    it 'throws an error if the path is not matched' do
      empty = described_class.new("e", {"name" => "cantfind", "path" => "$.missing_element"})
      expect{empty.process(classification)}.to raise_error(Extractors::PluckFieldExtractor::FailedMatch)
    end

    it 'ignores errors if we insist' do
      empty = described_class.new("e", {"name" => "cantfind", "path" => "$.missing_element", "if_missing" => "ignore"})
      result = empty.process(classification)

      expect(result).to be_a(Hash)
      expect(result).to eq({})
    end
  end
end
