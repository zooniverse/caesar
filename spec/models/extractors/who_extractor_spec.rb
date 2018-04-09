require 'spec_helper'

describe Extractors::WhoExtractor do
  let(:workflow){ create :workflow }
  let(:extractor){ described_class.new(key: "s", workflow_id: workflow.id) }
  let(:classification) { build :classification, user_id: 5 }

  it 'gives the user who performed the classification' do
    expect(extractor.process(classification)).to eq({"user_id" => 5})
  end
end
