require 'spec_helper'

describe Reducers::CountReducer do
  let(:reducer) { described_class.new }

  it 'counts classifications' do
    expect(reducer.reduce_into([], build(:subject_reduction)).data).to include('classifications' => 0)
    expect(reducer.reduce_into([
      Extract.new(classification_id: 1),
      Extract.new(classification_id: 1),
      Extract.new(classification_id: 2),
      Extract.new(classification_id: 2)
    ], build(:subject_reduction)).data).to include('classifications' => 2)
  end

  it 'counts extracts' do
    expect(reducer.reduce_into([], build(:subject_reduction)).data).to include('classifications' => 0)
    expect(reducer.reduce_into([
      Extract.new(classification_id: 1),
      Extract.new(classification_id: 1),
      Extract.new(classification_id: 2),
      Extract.new(classification_id: 2)
    ], build(:subject_reduction)).data).to include('extracts' => 4)
  end

  it 'ignores existing reduction data in default mode', :focus do
    default_reducer = described_class.new(reduction_mode: Reducer.reduction_modes[:default_reduction])
    reduction = build :subject_reduction, reducer_key: 'data', subgroup: '_default', data: { 'extracts' => 3, 'classifications' => 1 }

    result = default_reducer.reduce_into([Extract.new(classification_id: 1), Extract.new(classification_id: 1), Extract.new(classification_id: 2)], reduction)
    expect(result.data["classifications"]).to eq(2)
    expect(result.data["extracts"]).to eq(3)
  end

  it 'uses existing reduction data in running aggregation mode' do
    running_reducer = described_class.new(reduction_mode: Reducer.reduction_modes[:running_reduction])
    reduction = build :subject_reduction, reducer_key: 'data', subgroup: '_default', data: { 'extracts' => 3, 'classifications' => 1 }

    result = running_reducer.reduce_into([Extract.new(classification_id: 1), Extract.new(classification_id: 1), Extract.new(classification_id: 2)], reduction)
    expect(result.data["classifications"]).to eq(3)
    expect(result.data["extracts"]).to eq(6)
  end
end
