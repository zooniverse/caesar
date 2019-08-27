require 'spec_helper'

describe ReductionFetcher do
  it 'finds prefetched reductions' do
    w = create :workflow
    ur1 = create :user_reduction, reducible: w, subgroup: 's1', user_id: 1234
    create :user_reduction, reducible: w, subgroup: 's2', user_id: 1234

    fetcher = described_class.new(
      reducible_type: 'Workflow',
      reducible_id: w.id,
      user_id: 1234,
    ).for!(:reduce_by_user)

    fetcher.load!

    result = fetcher.retrieve_in_place(subgroup: 's1', user_id: 1234)

    expect(result).not_to be_nil
    expect(fetcher.retrieve_in_place(subgroup: 's1', user_id: 1234).id).to eq(ur1.id)
  end
end
