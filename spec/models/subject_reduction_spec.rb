require 'rails_helper'

RSpec.describe SubjectReduction, type: :model do

  it "should not fail to build the factory" do
    expect(build(:subject_reduction)).to be_valid
  end

  it '#prepare' do
    extract1 = create(:extract, user_id: 1)
    reduction = create(:subject_reduction, extracts: [extract1])
    prepared = reduction.prepare
    expected_attributes = %w[id data subject reducer_key created_at updated_at]
    expected_payload = reduction.attributes.slice(*expected_attributes)
    # add the formatted payload attributes before testing
    expected_payload['reducible'] = { 'id' => reduction.reducible_id, 'type' => reduction.reducible_type }
    expected_payload['subject'] = reduction.subject.attributes
    expect(expected_payload).to include(prepared)
  end

  it "should prepare auxiliary attributes" do
    extract1 = create(:extract, user_id: 1)
    extract2 = create(:extract, user_id: 2)
    extract3 = create(:extract, user_id: 3)
    reduction = create(:subject_reduction, extracts: [extract1, extract2, extract3])

    prepared = reduction.prepare
    expect(prepared[:subject]).to eq(reduction.subject.attributes)
  end
end
