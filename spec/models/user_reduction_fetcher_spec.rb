require 'spec_helper'

describe UserReductionFetcher do
  it 'finds prefetched reductions' do
    workflow = create :workflow
    reduction = create :user_reduction, reducible: workflow, subgroup: 's1', user_id: 1234
    create :user_reduction, reducible: workflow, subgroup: 's2', user_id: 1234

    fetcher = described_class.new(
      reducible_type: 'Workflow',
      reducible_id: workflow.id,
      user_id: 1234,
    )

    fetcher.load!

    result = fetcher.retrieve_in_place(subgroup: 's1', user_id: 1234)

    expect(result).not_to be_nil
    expect(fetcher.retrieve_in_place(subgroup: 's1', user_id: 1234).id).to eq(reduction.id)
  end
end
