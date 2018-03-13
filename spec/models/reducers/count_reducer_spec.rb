require 'spec_helper'

describe Reducers::CountReducer do
  def unwrap(reduction)
    reduction[0][:data]
  end

  let(:reducer) { described_class.new }

  it 'counts classifications' do
    expect(unwrap(reducer.process([]))).to include('classifications' => 0)
    expect(unwrap(reducer.process([Extract.new(classification_id: 1), Extract.new(classification_id: 1),
                            Extract.new(classification_id: 2), Extract.new(classification_id: 2)]))).to include('classifications' => 2)
  end

  it 'counts extracts' do
    expect(unwrap(reducer.process([]))).to include('extracts' => 0)
    expect(unwrap(reducer.process([Extract.new, Extract.new, Extract.new, Extract.new]))).to include('extracts' => 4)
  end

  it 'ignores existing reduction data in default mode' do
    s = Subject.create!
    default_reducer = described_class.new(reduction_mode: Reducer.reduction_modes[:default_reduction])
    reduction = SubjectReduction.create subject_id: s.id, reducer_key: 'data', subgroup: '_default', data: { 'extracts' => 3, 'classifications' => 1 }

    result = default_reducer.reduction_data_for([Extract.new(classification_id: 1), Extract.new(classification_id: 1), Extract.new(classification_id: 2)], reduction)
    expect(result["classifications"]).to eq(2)
    expect(result["extracts"]).to eq(3)
  end

  it 'uses existing reduction data in running aggregation mode' do
    s = Subject.create!
    running_reducer = described_class.new(reduction_mode: Reducer.reduction_modes[:running_reduction])
    reduction = SubjectReduction.create subject_id: s.id, reducer_key: 'data', subgroup: '_default', data: { 'extracts' => 3, 'classifications' => 1 }

    result = running_reducer.reduction_data_for([Extract.new(classification_id: 1), Extract.new(classification_id: 1), Extract.new(classification_id: 2)], reduction)
    expect(result["classifications"]).to eq(3)
    expect(result["extracts"]).to eq(6)
  end
end
