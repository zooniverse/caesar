require 'rails_helper'

RSpec.describe SubjectReduction, type: :model do

  it "should not fail to build the factory" do
    expect(build(:subject_reduction)).to be_valid
  end

  it "should prepare auxiliary attributes" do
    extract1 = create(:extract, user_id: 1)
    extract2 = create(:extract, user_id: 2)
    extract3 = create(:extract, user_id: 3)
    reduction = create(:subject_reduction, extracts: [extract1, extract2, extract3])

    prepared = reduction.prepare
    expect(prepared[:user_ids]).to include(extract1.user_id, extract2.user_id, extract3.user_id)
    expect(prepared[:subject]).to eq(reduction.subject.attributes)
  end
end
