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
      workflow = build(:workflow)
      expect( described_class.new(key: "s", workflow: workflow) ).not_to be_valid
      expect( described_class.new(key: "s", workflow: workflow, config: {"path" => "p"}) ).not_to be_valid
      expect( described_class.new(key: "s", workflow: workflow, config: {"name" => "n"}) ).not_to be_valid
      expect( described_class.new(key: "s", workflow: workflow, config: {"name" => "p", "path" => "n"}) ).to be_valid
    end

    it 'processes a classification' do
      simple = described_class.new(key: "s", config: {"name" => "whodunit", "path" => "$.user_id"})
      result = simple.process(classification)

      expect(result.blank?).to be(false)
      expect(result).to be_a(Hash)
      expect(result["whodunit"]).to eq(1234)

      complex = described_class.new(key: "c", config: {"name" => "how_fast", "path" => "$.metadata[0].shutter_speed"})
      result = complex.process(classification)

      expect(result.blank?).to be(false)
      expect(result).to be_a(Hash)
      expect(result["how_fast"]).to be_a(Array)
      expect(result["how_fast"]).to eq(["1/8", "1/4"])
    end

    it 'throws an error if the path is not matched' do
      empty = described_class.new(key: "e", config: {"name" => "cantfind", "path" => "$.missing_element"})
      expect{empty.process(classification)}.to raise_error(Extractors::PluckFieldExtractor::FailedMatch)
    end

    it 'ignores errors if we insist' do
      empty = described_class.new(key: "e", config: {"name" => "cantfind", "path" => "$.missing_element", "if_missing" => "ignore"})
      result = empty.process(classification)

      expect(result).to be_a(Hash)
      expect(result).to eq({})
    end
  end
end
