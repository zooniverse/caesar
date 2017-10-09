require 'spec_helper'

describe Reducers::SummaryStatisticsReducer do

  let(:workflow){ build_stubbed :workflow }
  let(:extracts){[
    build_stubbed(:extract, workflow_id: workflow.id, data: {"some_field" => 4.7}),
    build_stubbed(:extract, workflow_id: workflow.id, data: {"some_field" => "5"}),
    build_stubbed(:extract, workflow_id: workflow.id, data: {"some_field" => 3}),
    build_stubbed(:extract, workflow_id: workflow.id, data: {"some_other_field" => 2})
  ]}

  describe '#configuration' do
    it 'requires configuration fields' do
      r1 = described_class.new(workflow_id: workflow.id, config: {})
      expect(r1).not_to be_valid
      expect(r1.errors[:summarize_field]).to be_present
      expect(r1.errors[:operations]).to be_present
    end
    it 'requires a valid field to summarize' do
      r1 = described_class.new(workflow_id: workflow.id, config: {"summarize_field" => "simple_field"})
      r2 = described_class.new(workflow_id: workflow.id, config: {"summarize_field" => "complex.field"})
      r1.validate
      r2.validate

      expect(r1.errors[:summarize_field]).not_to be_present
      expect(r2.errors[:summarize_field]).not_to be_present

      r3 = described_class.new(workflow_id: workflow.id, config: {"summarize_field" => "bad."})
      r3.validate

      expect(r3.errors[:summarize_field]).to be_present
    end

    it 'requires a valid list of operations' do
      r1 = described_class.new(workflow_id: workflow.id, config: {"operations" => 0})
      r1.validate
      expect(r1.errors[:operations]).to be_present

      r2 = described_class.new(workflow_id: workflow.id, config: {"operations" => "blah"})
      r2.validate
      expect(r2.errors[:operations]).to be_present

      r3 = described_class.new(workflow_id: workflow.id, config: {"operations" => "sum"})
      r3.validate
      expect(r3.errors[:operations]).not_to be_present

      r4 = described_class.new(workflow_id: workflow.id, config: {"operations" => []})
      r4.validate
      expect(r4.errors[:operations]).to be_present

      r5 = described_class.new(workflow_id: workflow.id, config: {"operations" => [0]})
      r5.validate
      expect(r5.errors[:operations]).to be_present

      r6 = described_class.new(workflow_id: workflow.id, config: {"operations" => ["blah"]})
      r6.validate
      expect(r6.errors[:operations]).to be_present

      r7 = described_class.new(workflow_id: workflow.id, config: {"operations" => ["sum"]})
      r7.validate
      expect(r7.errors[:operations]).not_to be_present

      r8 = described_class.new(workflow_id: workflow.id, config: {"operations" => ["sum", 0]})
      r8.validate
      expect(r8.errors[:operations]).to be_present

      r9 = described_class.new(workflow_id: workflow.id, config: {"operations" => ["sum", "blah"]})
      r9.validate
      expect(r9.errors[:operations]).to be_present

      r10 = described_class.new(workflow_id: workflow.id, config: {"operations" => ["sum", "mean"]})
      r10.validate
      expect(r10.errors[:operations]).not_to be_present

    end

    it 'reads the config fields correctly' do
      r1 = described_class.new(workflow_id: workflow.id, config: {"summarize_field" => "simple_field"})
      r2 = described_class.new(workflow_id: workflow.id, config: {"summarize_field" => "complex.field"})

      expect(r1.send(:summarize_field)).to eq("simple_field")
      expect(r2.send(:summarize_field)).to eq("complex.field")

      expect(r1.send(:extractor_name)).to be_nil
      expect(r2.send(:extractor_name)).not_to be_nil
      expect(r2.send(:extractor_name)).to eq("complex")

      expect(r1.send(:field_name)).to eq("simple_field")
      expect(r2.send(:field_name)).to eq("field")

      r3 = described_class.new(workflow_id: workflow.id, config: {"operations" => ["sum", "mean"]})
      expect(r3.send(:operations)).to eq(["sum", "mean"])

      r4 = described_class.new(workflow_id: workflow.id, config: {"operations" => "sum"})
      expect(r4.send(:operations)).to eq(["sum"])

      r5 = described_class.new(workflow_id: workflow.id, config: {"operations" => ["sum","sum"]})
      expect(r5.send(:operations)).to eq(["sum"])
    end
  end

  describe '#reduction_data_for' do
    it 'considers only relevant extracts' do
      r1 = described_class.new(workflow_id: workflow.id, config: {"summarize_field" => "simple_field"})
      r2 = described_class.new(workflow_id: workflow.id, config: {"summarize_field" => "complex.field"})

      extracts = [
        build_stubbed(:extract, extractor_key: "foo"),
        build_stubbed(:extract, extractor_key: "complex"),
        build_stubbed(:extract, extractor_key: "foo"),
        build_stubbed(:extract, extractor_key: "complex"),
        build_stubbed(:extract, extractor_key: "complex")
      ]

      allow(r1).to receive(:extracts).and_return(extracts)
      allow(r2).to receive(:extracts).and_return(extracts)

      expect(r1.send(:relevant_extracts)).to eq(extracts)
      expect(r2.send(:relevant_extracts)).not_to eq(extracts)
      expect(r2.send(:relevant_extracts).count).to eq(3)
    end

    it 'computes minimum correctly' do
      reducer = described_class.new(config: {"summarize_field" => "some_field", "operations" => ["min"]})
      result = reducer.reduction_data_for(extracts)
      expect(result["min"]).to be_present
      expect(result["min"]).to eq(3)
    end

    it 'computes maximum correctly' do
      reducer = described_class.new(config: {"summarize_field" => "some_field", "operations" => ["max"]})
      result = reducer.reduction_data_for(extracts)
      expect(result["max"]).to be_present
      expect(result["max"]).to eq(5)
    end

    it 'counts correctly' do
      extracts = [
        build_stubbed(:extract, data: {"some_field" => 4.7}),
        build_stubbed(:extract, data: {"some_field" => 4.7}),
        build_stubbed(:extract, data: {"some_field" => "5"}),
        build_stubbed(:extract, data: {"some_field" => 3}),
        build_stubbed(:extract, data: {"some_other_field" => 2})
      ]

      reducer = described_class.new(config: {"summarize_field" => "some_field", "operations" => ["count"]})
      result = reducer.reduction_data_for(extracts)
      expect(result["count"]).to be_present
      expect(result["count"]).to eq(4)
    end

    it 'computes sum correctly' do
      reducer = described_class.new(config: {"summarize_field" => "some_field", "operations" => ["sum"]})
      result = reducer.reduction_data_for(extracts)
      expect(result["sum"]).to be_present
      expect(result["sum"]).to eq(12.7)
    end

    it 'computes product correctly' do
      reducer = described_class.new(config: {"summarize_field" => "some_field", "operations" => ["product"]})
      result = reducer.reduction_data_for(extracts)
      expect(result["product"]).to be_present
      expect(result["product"]).to eq(70.5)
    end

    it 'computes mean correctly' do
      reducer = described_class.new(config: {"summarize_field" => "some_field", "operations" => ["mean"]})
      result = reducer.reduction_data_for(extracts)
      expect(result["mean"]).to be_present
      expect(result["mean"]).to be_within(0.0001).of(4.2333)
    end

    it 'computes variance correctly' do
      reducer = described_class.new(config: {"summarize_field" => "some_field", "operations" => ["variance"]})
      result = reducer.reduction_data_for(extracts)
      expect(result["variance"]).to be_present
      expect(result["variance"]).to be_within(0.0001).of(1.16333)
    end

    it 'computes sse correctly' do
      reducer = described_class.new(config: {"summarize_field" => "some_field", "operations" => ["sse"]})
      result = reducer.reduction_data_for(extracts)
      expect(result["sse"]).to be_present
      expect(result["sse"]).to be_within(0.0001).of(2.32666)
    end

    it 'computes stdev correctly' do
      reducer = described_class.new(config: {"summarize_field" => "some_field", "operations" => ["stdev"]})
      result = reducer.reduction_data_for(extracts)
      expect(result["stdev"]).to be_present
      expect(result["stdev"]).to be_within(0.0001).of(1.07857)
    end

    it 'computes median correctly' do
      reducer = described_class.new(config: {"summarize_field" => "some_field", "operations" => ["median"]})
      result = reducer.reduction_data_for(extracts)
      expect(result["median"]).to be_present
      expect(result["median"]).to eq(4.7)
    end

    it 'computes mode correctly' do
      extracts = [
        build_stubbed(:extract, data: {"some_field" => "5"}),
        build_stubbed(:extract, data: {"some_field" => 4.7}),
        build_stubbed(:extract, data: {"some_field" => 4.7}),
        build_stubbed(:extract, data: {"some_field" => 3}),
        build_stubbed(:extract, data: {"some_other_field" => 2})
      ]

      reducer = described_class.new(config: {"summarize_field" => "some_field", "operations" => ["mode"]})
      result = reducer.reduction_data_for(extracts)
      expect(result["mode"]).to be_present
      expect(result["mode"]).to eq(4.7)
    end

    it 'computes first correctly' do
      reducer = described_class.new(config: {"summarize_field" => "some_field", "operations" => ["first"]})
      result = reducer.reduction_data_for(extracts)
      expect(result["first"]).to be_present
      expect(result["first"]).to eq(4.7)
    end

  end
end
