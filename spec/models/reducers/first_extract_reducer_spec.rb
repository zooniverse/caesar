require 'spec_helper'

describe Reducers::FirstExtractReducer do

  def unwrap(reduction)
    reduction[0][:data]
  end

  let(:extracts) do
    [
      Extract.new(data: {"foo" => "bar", "bar" => "baz"}),
      Extract.new(data: {"foo" => "bar", "bar" => "bar"})
    ]

  end

  it 'handles an empty extract list' do
    reducer = described_class.new
    expect(reducer.reduction_data_for([], nil)).to eq({})
  end

  it 'returns whatever is in the first extract no matter what' do
    reducer = described_class.new

    expect(reducer.reduction_data_for(extracts, nil)).to eq({"foo" => "bar", "bar" => "baz"})
    expect(reducer.reduction_data_for([extracts[1]], nil)).to eq({"foo" => "bar", "bar" => "bar"})
  end

  it 'works correctly in default aggregation mode' do
    s = Subject.create!
    default_reducer = described_class.new(reduction_mode: Reducer.reduction_modes[:default_reduction])
    reduction = SubjectReduction.create subject_id: s.id, reducer_key: 'data', subgroup: '_default'

    expect(default_reducer.reduction_data_for(extracts, reduction)).to eq({"foo" => "bar", "bar" => "baz"})
  end

  it 'works correctly in running aggregation mode' do
    s = Subject.create!
    running_reducer = described_class.new(reduction_mode: Reducer.reduction_modes[:running_reduction])
    reduction = SubjectReduction.create subject_id: s.id, reducer_key: 'data', subgroup: '_default', data: { 'value' => 'first' }

    expect(running_reducer.reduction_data_for(extracts, reduction)).to eq({'value'=>'first'})
  end
end
