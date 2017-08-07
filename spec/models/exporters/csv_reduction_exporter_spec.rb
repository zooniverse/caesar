require 'spec_helper'

describe Exporters::CsvReductionExporter do
  let(:workflow) { Workflow.create! }
  let(:subject) { Subject.create! }

  let(:exporter) { described_class.new }
  let(:sample) {
    Reduction.new(
      reducer_id: "x",
      workflow_id: workflow.id,
      subject_id: subject.id,
      data: {"key1" => "val1", "key2" => "val2"}
    )
  }

  before do
    if File.exist?"tmp/reductions_#{workflow.id}.csv"
      File.delete("tmp/reductions_#{workflow.id}.csv")
    end

    Reduction.new(
      reducer_id: "x",
      workflow_id: workflow.id,
      subject_id: Subject.create!.id,
      data: {"key2" => "val2"}
    ).save
    Reduction.new(
      reducer_id: "x",
      workflow_id: workflow.id,
      subject_id: Subject.create!.id,
      data: {"key2" => "val2"}
    ).save
    sample.save
    Reduction.new(
      reducer_id: "x",
      workflow_id: workflow.id,
      subject_id: Subject.create!.id,
      data: {"key1" => "val1", "key2" => "val2"}
    ).save
    Reduction.new(
      reducer_id: "x",
      workflow_id: workflow.id,
      subject_id: Subject.create!.id,
      data: {"key1" => "val1", "key3" => "val3"}
    ).save
    Reduction.new(
      reducer_id: "x",
      workflow_id: Workflow.create!.id,
      subject_id: Subject.create!.id,
      data: {"key4" => "val4"}
    ).save

  end

  it '#get_unique_json_cols should calculate keys correctly' do
    keys = exporter.get_unique_json_cols(workflow.id)
    expect(keys.size).to eq(3)
    expect(keys).to include("key1")
    expect(keys).to include("key2")
    expect(keys).to include("key3")
    expect(keys).not_to include("key4")
  end

  it 'should get the list of model columns correctly' do
    keys = exporter.get_model_cols
    expect(keys).to include("id")
    expect(keys).to include("reducer_id")
    expect(keys).not_to include("data")
    expect(keys).not_to include("sdfjkasdfjk")
  end

  it 'should give the right header row for the csv' do
    keys = exporter.get_csv_headers(workflow.id)
    expect(keys).to include("id")
    expect(keys).to include("reducer_id")
    expect(keys).not_to include("data")
    expect(keys).not_to include("sdfjkasdfjk")
    expect(keys).to include("data.key1")
    expect(keys).not_to include("key1")
    expect(keys).to include("data.key2")
    expect(keys).to include("data.key3")
    expect(keys).not_to include("data.key4")
  end

  it 'should build the rows properly' do
    row = exporter.extract_row(
      sample,
      exporter.get_model_cols,
      exporter.get_unique_json_cols(workflow.id)
    )

    expect(row).to include("x")
    expect(row).to include("val1")
    expect(row).to include("val2")
    expect(row).to include("")
    expect(row).not_to include("val3")
    expect(row).to include(workflow.id)
  end

  it 'should create the right file' do
    exporter.dump(workflow.id)
    expect(File.exist?("tmp/reductions_#{workflow.id}.csv")).to be(true)
  end
end
