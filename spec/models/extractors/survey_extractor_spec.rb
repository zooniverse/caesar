require 'spec_helper'

describe Extractors::SurveyExtractor do
  def make_annotation(choice)
    {
      "task" => "T0",
      "value" => [
        {"choice" => choice, "answers" => {"HWMN" => "1"}, "filters" => {}}
      ]
    }
  end

  let(:annotations) { [make_annotation("OTHER")] }
  let(:workflow){ create :workflow }

  let(:classification) do
    Classification.new(annotations: annotations)
  end

  subject(:extractor) { described_class.new(key: 's', workflow_id: workflow.id) }

  describe '#process' do
    it 'can ignore missing task' do
      annotations.clear

      extractor.config["if_missing"] = "ignore"
      expect(extractor.process(classification)).to eq({})

      extractor.config["if_missing"] = "nothing_here"
      extractor.config["nothing_here_choice"] = "NTHNGHR"
      expect(extractor.process(classification)).to eq("NTHNGHR" => 1)

      extractor.config["if_missing"] = "error"
      expect { extractor.process(classification) }.to raise_error(Extractors::SurveyExtractor::MissingAnnotation)
    end

    it 'converts empty value lists to nothing_here if configured' do
      extractor.config["nothing_here_choice"] = "NTHNGHR"
      annotations[0]["value"] = []
      expect(extractor.process(classification)).to eq("NTHNGHR" => 1)
    end

    it 'detects the nothing_here value' do
      annotations[0]["value"][0]["choice"] = "NTHNGHR"
      expect(extractor.process(classification)).to eq("NTHNGHR" => 1)
    end

    it 'detects a single choice' do
      annotations[0]["value"][0]["choice"] = "RCCN"
      expect(extractor.process(classification)).to eq("RCCN" => 1)
    end

    it 'detects a multiple choices' do
      annotations[0]["value"][1] = annotations[0]["value"][0].dup
      annotations[0]["value"][2] = annotations[0]["value"][0].dup

      annotations[0]["value"][0]["choice"] = "RCCN"
      annotations[0]["value"][1]["choice"] = "RCCN"
      annotations[0]["value"][2]["choice"] = "BBN"
      expect(extractor.process(classification)).to eq("RCCN" => 2, "BBN" => 1)
    end

    it 'detects a multiple annotations for this task' do
      annotations[0] = make_annotation("RCCN")
      annotations[1] = make_annotation("RCCN")
      annotations[2] = make_annotation("BBN")
      expect(extractor.process(classification)).to eq("RCCN" => 2, "BBN" => 1)
    end
  end
end
