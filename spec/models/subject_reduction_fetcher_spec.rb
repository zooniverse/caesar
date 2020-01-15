require 'spec_helper'

describe SubjectReductionFetcher do
  it 'finds prefetched reductions' do
    workflow = create :workflow
    subject = create :subject
    reduction = create :subject_reduction, reducible: workflow, subgroup: 's1', subject: subject
    create :subject_reduction, reducible: workflow, subgroup: 's2', subject: subject

    fetcher = described_class.new(
      reducible_type: 'Workflow',
      reducible_id: workflow.id,
      subject_id: subject.id,
    )

    fetcher.load!

    result = fetcher.retrieve_in_place(subgroup: 's1', subject_id: subject.id)

    expect(result).not_to be_nil
    expect(fetcher.retrieve_in_place(subgroup: 's1', subject_id: subject.id).id).to eq(reduction.id)
  end
end
