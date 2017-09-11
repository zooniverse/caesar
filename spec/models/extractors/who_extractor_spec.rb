require 'spec_helper'

describe Extractors::WhoExtractor do
  let(:extractor){ described_class.new(key: "s") }
  let(:classification){
    # Classification.new({userId: 5, links: []})
    Classification.new(
      "links"=>{
        "project"=>"2439",
        "user"=>"5",
        "workflow"=>"1234",
        "workflow_content"=>"1716",
        "subjects"=>"4567"
      }
    )
  }

  it 'gives the user who performed the classification' do
    expect(extractor.process(classification)).to eq({"user_id" => 5})
  end
end
