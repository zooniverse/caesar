require 'spec_helper'

describe Reducers::SummaryStatisticsReducer do

  let(:workflow){ build_stubbed :workflow }

  let(:extracts1){[
    build_stubbed(:extract, data: {"some_field" => 4.7}),
    build_stubbed(:extract, data: {"some_field" => "5"})
  ]}

  let(:extracts2){[
    build_stubbed(:extract, data: {"some_field" => 3}),
    build_stubbed(:extract, data: {"some_other_field" => 2})
  ]}

  let(:extracts){ extracts1 + extracts2 }

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

  describe 'miscellaneous' do
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
  end

  describe '#reduce_into' do

    describe 'computing min' do
      it 'computes correctly in default mode' do
        reduction = build :subject_reduction

        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["min"]},
          reduction_mode: Reducer.reduction_modes[:default_reduction]
        )

        reducer2 = reducer1.clone

        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["min"]).to be_present
        expect(result.data["min"]).to eq(4.7)

        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["min"]).to be_present
        expect(result.data["min"]).to eq(3)
      end

      it 'computes correctly in running aggregation mode' do
        reduction = build :subject_reduction, store: { "min" => 4 }

        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["min"]},
          reduction_mode: Reducer.reduction_modes[:running_reduction]
        )

        reducer2 = reducer1.clone

        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["min"]).to be_present
        expect(result.data["min"]).to eq(4)

        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["min"]).to be_present
        expect(result.data["min"]).to eq(3)
      end
    end

    describe 'computing first' do
      it 'computes correctly in default mode' do
        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["first"]},
          reduction_mode: Reducer.reduction_modes[:default_reduction]
        )

        reducer2 = reducer1.clone

        reduction = build :subject_reduction
        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["first"]).to be_present
        expect(result.data["first"]).to eq(4.7)

        reduction = build :subject_reduction
        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["first"]).to be_present
        expect(result.data["first"]).to eq(3)
      end

      it 'computes correctly in running aggregation mode' do
        reduction = build :subject_reduction

        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["first"]},
          reduction_mode: Reducer.reduction_modes[:running_reduction]
        )

        reducer2 = reducer1.clone

        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["first"]).to be_present
        expect(result.data["first"]).to eq(4.7)

        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["first"]).to be_present
        expect(result.data["first"]).to eq(4.7)
      end
    end

    describe 'computing max' do
      it 'computes correctly in default mode' do
        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["max"]},
          reduction_mode: Reducer.reduction_modes[:default_reduction]
        )

        reducer2 = reducer1.clone

        reduction = build :subject_reduction
        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["max"]).to be_present
        expect(result.data["max"]).to eq(5)

        reduction = build :subject_reduction
        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["max"]).to be_present
        expect(result.data["max"]).to eq(3)
      end

      it 'computes correctly in running aggregation mode' do
        reduction = build :subject_reduction, store: { }

        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["max"]},
          reduction_mode: Reducer.reduction_modes[:running_reduction]
        )

        reducer2 = reducer1.clone

        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["max"]).to be_present
        expect(result.data["max"]).to eq(5)

        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["max"]).to be_present
        expect(result.data["max"]).to eq(5)
      end
    end

    describe 'computing count' do
      it 'computes correctly in default mode' do
        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["count"]},
          reduction_mode: Reducer.reduction_modes[:default_reduction]
        )

        reducer2 = reducer1.clone

        reduction = build :subject_reduction
        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["count"]).to be_present
        expect(result.data["count"]).to eq(2)

        reduction = build :subject_reduction
        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["count"]).to be_present
        expect(result.data["count"]).to eq(1)
      end

      it 'computes correctly in running aggregation mode' do
        reduction = build :subject_reduction, store: { "count" => 5 }

        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["count"]},
          reduction_mode: Reducer.reduction_modes[:running_reduction]
        )

        reducer2 = reducer1.clone

        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["count"]).to be_present
        expect(result.data["count"]).to eq(7)

        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["count"]).to be_present
        expect(result.data["count"]).to eq(8)
      end
    end

    describe 'computing sum' do
      it 'computes correctly in default mode' do
        reduction = build :subject_reduction

        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["sum"]},
          reduction_mode: Reducer.reduction_modes[:default_reduction]
        )

        reducer2 = reducer1.clone

        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["sum"]).to be_present
        expect(result.data["sum"]).to eq(9.7)

        reduction = build :subject_reduction
        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["sum"]).to be_present
        expect(result.data["sum"]).to eq(3)
      end

      it 'computes correctly in running aggregation mode' do
        reduction = build :subject_reduction, store: { "sum" => 5 }

        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["sum"]},
          reduction_mode: Reducer.reduction_modes[:running_reduction]
        )

        reducer2 = reducer1.clone

        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["sum"]).to be_present
        expect(result.data["sum"]).to eq(14.7)

        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["sum"]).to be_present
        expect(result.data["sum"]).to eq(17.7)
      end
    end

    describe 'computing product' do
      it 'computes correctly in default mode' do
        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["product"]},
          reduction_mode: Reducer.reduction_modes[:default_reduction]
        )

        reducer2 = reducer1.clone

        reduction = build :subject_reduction
        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["product"]).to be_present
        expect(result.data["product"]).to eq(23.5)

        reduction = build :subject_reduction
        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["product"]).to be_present
        expect(result.data["product"]).to eq(3)
      end

      it 'computes correctly in running aggregation mode' do
        reduction = build :subject_reduction

        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["product"]},
          reduction_mode: Reducer.reduction_modes[:running_reduction]
        )

        reducer2 = reducer1.clone

        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["product"]).to be_present
        expect(result.data["product"]).to eq(23.5)

        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["product"]).to be_present
        expect(result.data["product"]).to eq(70.5)
      end
    end

    describe 'computing mean' do
      it 'computes correctly in default mode' do
        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["mean"]},
          reduction_mode: Reducer.reduction_modes[:default_reduction]
        )

        reducer2 = reducer1.clone

        reduction = build :subject_reduction
        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["mean"]).to be_present
        expect(result.data["mean"]).to eq(4.85)

        reduction = build :subject_reduction
        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["mean"]).to be_present
        expect(result.data["mean"]).to eq(3)
      end

      it 'computes correctly in running aggregation mode' do
        reduction = build :subject_reduction

        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["mean"]},
          reduction_mode: Reducer.reduction_modes[:running_reduction]
        )

        reducer2 = reducer1.clone

        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["mean"]).to be_present
        expect(result.data["mean"]).to eq(4.85)

        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["mean"]).to be_present
        expect(result.data["mean"]).to be_within(0.0001).of(4.2333)
      end
    end

    describe 'computing sse' do
      it 'computes correctly in default mode' do
        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["sse"]},
          reduction_mode: Reducer.reduction_modes[:default_reduction]
        )

        reducer2 = reducer1.clone

        reduction = build :subject_reduction
        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["sse"]).to be_present
        expect(result.data["sse"]).to be_within(0.0001).of(0.045)

        reduction = build :subject_reduction
        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["sse"]).to be_present
        expect(result.data["sse"]).to eq(0)
      end

      it 'computes correctly in running aggregation mode' do
        reduction = build :subject_reduction

        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["sse"]},
          reduction_mode: Reducer.reduction_modes[:running_reduction]
        )

        reducer2 = reducer1.clone

        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["sse"]).to be_present
        expect(result.data["sse"]).to be_within(0.0001).of(0.045)

        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["sse"]).to be_present
        expect(result.data["sse"]).to be_within(0.0001).of(2.3266)
      end
    end

    describe 'computing variance' do
      it 'computes correctly in default mode' do
        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["variance"]},
          reduction_mode: Reducer.reduction_modes[:default_reduction]
        )

        reducer2 = reducer1.clone

        reduction = build :subject_reduction
        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["variance"]).to be_present
        expect(result.data["variance"]).to be_within(0.0001).of(0.045)

        reduction = build :subject_reduction
        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data.key?("variance")).to be(true)
        expect(result.data["variance"]).to eq(nil)
      end

      it 'computes correctly in running aggregation mode' do
        reduction = build :subject_reduction

        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["variance"]},
          reduction_mode: Reducer.reduction_modes[:running_reduction]
        )

        reducer2 = reducer1.clone

        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["variance"]).to be_present
        expect(result.data["variance"]).to be_within(0.0001).of(0.045)

        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["variance"]).to be_present
        expect(result.data["variance"]).to be_within(0.0001).of(1.1633)
      end
    end

    describe 'computing stdev' do
      it 'computes correctly in default mode' do
        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["stdev"]},
          reduction_mode: Reducer.reduction_modes[:default_reduction]
        )

        reducer2 = reducer1.clone

        reduction = build :subject_reduction
        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["stdev"]).to be_present
        expect(result.data["stdev"]).to be_within(0.0001).of(0.2121)

        reduction = build :subject_reduction
        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data.key?("stdev")).to be(true)
        expect(result.data["stdev"]).to eq(nil)
      end

      it 'computes correctly in running aggregation mode' do
        reduction = build :subject_reduction

        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["stdev"]},
          reduction_mode: Reducer.reduction_modes[:running_reduction]
        )

        reducer2 = reducer1.clone

        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["stdev"]).to be_present
        expect(result.data["stdev"]).to be_within(0.0001).of(0.2121)

        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["stdev"]).to be_present
        expect(result.data["stdev"]).to be_within(0.0001).of(1.07857)
      end
    end

    describe 'computing median' do
      it 'computes correctly in default mode' do
        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["median"]},
          reduction_mode: Reducer.reduction_modes[:default_reduction]
        )

        reducer2 = reducer1.clone

        reduction = build :subject_reduction
        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["median"]).to be_present
        expect(result.data["median"]).to be_within(0.0001).of(4.85)

        reduction = build :subject_reduction
        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["median"]).to eq(3)
      end

      it 'computes correctly in running aggregation mode' do
        reduction = build :subject_reduction

        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["median"]},
          reduction_mode: Reducer.reduction_modes[:running_reduction]
        )

        reducer2 = reducer1.clone

        result = reducer1.reduce_into(extracts1, reduction)
        expect(result.data["median"]).to be_present
        expect(result.data["median"]).to be_within(0.0001).of(4.85)

        result = reducer2.reduce_into(extracts2, reduction)
        expect(result.data["median"]).to be_present
        expect(result.data["median"]).to be_within(0.0001).of(4.7)
      end
    end

    describe 'computing mode' do
      let(:mode_extracts1){[
        build_stubbed(:extract, data: {"some_field" => "5"}),
        build_stubbed(:extract, data: {"some_field" => 4.7}),
        build_stubbed(:extract, data: {"some_field" => 4.7}),
      ]}
      let(:mode_extracts2){[
        build_stubbed(:extract, data: {"some_field" => 4.7}),
        build_stubbed(:extract, data: {"some_field" => 5}),
        build_stubbed(:extract, data: {"some_field" => 5})
      ]}

      it 'computes correctly in default mode' do
        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["mode"]},
          reduction_mode: Reducer.reduction_modes[:default_reduction]
        )

        reducer2 = reducer1.clone

        reduction = build :subject_reduction
        result = reducer1.reduce_into(mode_extracts1, reduction)
        expect(result.data["mode"]).to be_present
        expect(result.data["mode"]).to eq(4.7)

        reduction = build :subject_reduction
        result = reducer2.reduce_into(mode_extracts2, reduction)
        expect(result.data["mode"]).to be_present
        expect(result.data["mode"]).to eq(5)
      end

      it 'computes correctly in running aggregation mode' do
        reduction = build :subject_reduction, store: { "frequencies": { "4.7" => 2 } }

        reducer1 = described_class.new(
          config: {"summarize_field" => "some_field", "operations" => ["mode"]},
          reduction_mode: Reducer.reduction_modes[:running_reduction]
        )

        reducer2 = reducer1.clone

        result = reducer1.reduce_into(mode_extracts1, reduction)
        expect(result.data["mode"]).to be_present
        expect(result.data["mode"]).to eq(4.7)

        result = reducer2.reduce_into(mode_extracts2, reduction)
        expect(result.data["mode"]).to be_present
        expect(result.data["mode"]).to eq(4.7)
      end
    end
  end
end
