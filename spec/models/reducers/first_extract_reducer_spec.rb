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
    expect(reducer.reduce_into([], build(:subject_reduction)).data).to eq({})
  end

  it 'returns whatever is in the first extract no matter what' do
    reducer = described_class.new

    expect(reducer.reduce_into(extracts, build(:subject_reduction)).data).to eq({"foo" => "bar", "bar" => "baz"})
    expect(reducer.reduce_into([extracts[1]], build(:subject_reduction)).data).to eq({"foo" => "bar", "bar" => "bar"})
  end

  it 'works correctly in default aggregation mode' do
    default_reducer = described_class.new(reduction_mode: Reducer.reduction_modes[:default_reduction])
    reduction = build :subject_reduction, reducer_key: 'data', subgroup: '_default'

    expect(default_reducer.reduce_into(extracts, reduction).data).to eq({"foo" => "bar", "bar" => "baz"})
  end

  it 'works correctly in running aggregation mode' do
    running_reducer = described_class.new(reduction_mode: Reducer.reduction_modes[:running_reduction])
    reduction = build :subject_reduction, reducer_key: 'data', subgroup: '_default', data: { 'value' => 'first' }

    expect(running_reducer.reduce_into(extracts, reduction).data).to eq({'value'=>'first'})
  end
end
