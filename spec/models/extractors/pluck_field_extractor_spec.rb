require 'spec_helper'

describe Extractors::PluckFieldExtractor do
  let(:workflow){ create :workflow }
  let(:subject){ create :subject, metadata: {
    "shutter_speed" => ["1/8", "1/4"],
    "badmatch" => "SERVAL"
  } }
  let(:classification) do
    Classification.new(
      "id" => "5678",
      "annotations" => [{ "some_key": "some_value" }],
      "metadata" => { "classified_at" => "1234" },
      "links" => {
        "workflow" => workflow.id,
        "project" => workflow.project_id,
        "user" => "1234",
        "subjects" => [
          subject.id
        ]
      }
    )
  end

  describe '#process' do
    it 'requires config to be set' do
      workflow = build(:workflow)
      expect( described_class.new(key: "s", workflow: workflow) ).not_to be_valid
      expect( described_class.new(key: "s", workflow: workflow, config: { field_map: { "n" => "p" } }) ).to be_valid
    end

    it 'processes a classification for a single key' do
      simple = described_class.new(key: "s", config: {"field_map" => { "whodunit" => "$.user_id" }})
      result = simple.process(classification)

      expect(result.blank?).to be(false)
      expect(result).to be_a(Hash)
      expect(result["whodunit"]).to eq(1234)

      complex = described_class.new(key: "c", config: { "field_map" => { "how_fast" => "$.subject.metadata.shutter_speed"}})
      result = complex.process(classification)

      expect(result.blank?).to be(false)
      expect(result).to be_a(Hash)
      expect(result["how_fast"]).to be_a(Array)
      expect(result["how_fast"]).to eq(["1/8", "1/4"])
    end

    it 'processes a classification to retrieve multiple keys' do
      extractor = described_class.new(key: "c", config: { "field_map" => {
        "whodunit" => "$.user_id",
        "how_fast" => "$.subject.metadata.shutter_speed"
      }})

      result = extractor.process(classification)
      expect(result.blank?).to be(false)
      expect(result).to be_a(Hash)
      expect(result["whodunit"]).to eq(1234)
      expect(result["how_fast"]).to be_a(Array)
      expect(result["how_fast"]).to eq(["1/8", "1/4"])
    end

    it 'applies transformations if asked' do
      extractor = described_class.new(key: "c", config: { "field_map" => {
        "num" => {"path"=> "$.user_id", "transform" => "to_i" },
        "what" => {"path"=> "$.subject.metadata.badmatch", "transform" => "downcase" }
      }})

      result = extractor.process(classification)
      expect(result).to be_a(Hash)
      expect(result['what']).to eq("serval")
      expect(result['num']).to eq(1234)
    end

    it 'throws an error if the path is not matched' do
      empty = described_class.new(key: "e", config: {"field_map" => {"cantfind" => "$.missing_element"}})
      expect{empty.process(classification)}.to raise_error(Extractors::PluckFieldExtractor::FailedMatch)
    end

    it 'ignores errors if we insist' do
      empty = described_class.new(key: "e", config: {"field_map" => {"cantfind" => "$.missing_element"}, "if_missing" => "ignore"})
      result = empty.process(classification)

      expect(result).to be_a(Hash)
      expect(result).to eq({"cantfind" => nil})
    end
  end
end
