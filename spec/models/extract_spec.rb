require 'rails_helper'

RSpec.describe Extract, type: :model do

  it "should not fail to build the factory" do
    expect(build(:extract)).to be_valid
  end

  describe "a relevant reduction" do
    let(:extract) { create(:extract, user_id: 1) }
    let(:rr) { create(:user_reduction, data: {skill: 15}, user_id: 1, reducer_key: 'skillz') }
    let(:parsed) { JSON.parse(extract.to_json) }

    it 'serializes a relevant reduction' do
      extract.relevant_reduction = rr
      expect(parsed).to include("relevant_reduction" => hash_including("id" => rr.id, "data" => rr.data))
    end

    it 'serializes nil if not associated' do
     expect(parsed).to include("relevant_reduction" => nil)
    end
  end
end
