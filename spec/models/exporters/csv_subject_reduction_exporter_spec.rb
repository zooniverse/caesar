require 'spec_helper'

describe Exporters::CsvSubjectReductionExporter do
  let(:workflow) { create :workflow }
  let(:subject) { Subject.create! }
  let(:exporter) { described_class.new reducible_id: workflow.id }
  let(:sample){
    SubjectReduction.new(
      reducer_key: "x",
      reducible: workflow,
      subject_id: subject.id,
      data: {"key1" => "val1", "key2" => "val2", "key5" => {"foo" => "bar"}, "key6" => ["foo", "bar"]}
    )
  }

  before do
    if File.exist?"tmp/reductions_#{workflow.id}.csv"
      File.delete("tmp/reductions_#{workflow.id}.csv")
    end

    SubjectReduction.new(
      reducer_key: "x",
      reducible: workflow,
      subject_id: Subject.create!.id,
      data: {"key2" => "val2"}
    ).save
    SubjectReduction.new(
      reducer_key: "x",
      reducible: workflow,
      subject_id: Subject.create!.id,
      data: {"key2" => "val2"}
    ).save
    sample.save
    SubjectReduction.new(
      reducer_key: "x",
      reducible: workflow,
      subject_id: Subject.create!.id,
      data: {"key1" => "val1", "key2" => "val2"}
    ).save
    SubjectReduction.new(
      reducer_key: "x",
      reducible: workflow,
      subject_id: Subject.create!.id,
      data: {"key1" => "val1", "key3" => "val3"}
    ).save
    SubjectReduction.new(
      reducer_key: "x",
      reducible: create(:workflow),
      subject_id: Subject.create!.id,
      data: {"key4" => "val4"}
    ).save
  end

  it 'should give the right header row for the csv' do
    keys = exporter.get_csv_headers
    expect(keys).to include("id")
    expect(keys).to include("reducer_key")
    expect(keys).not_to include("data")
    expect(keys).not_to include("sdfjkasdfjk")
    expect(keys).to include("data.key1")
    expect(keys).not_to include("key1")
    expect(keys).to include("data.key2")
    expect(keys).to include("data.key3")
    expect(keys).not_to include("data.key4")
  end

  it 'should build the rows properly' do
    row = exporter.extract_row(sample)

    expect(row).to include("x")
    expect(row).to include("val1")
    expect(row).to include("val2")
    expect(row).to include("")
    expect(row).not_to include("val3")
    expect(row).to include({"foo" => "bar"}.to_json)
    expect(row).to include(["foo", "bar"].to_json)
    expect(row).to include(workflow.id)
  end

  it 'should create the right file' do
    exporter.dump
    expect(File.exist?("tmp/subject_reductions_#{workflow.id}.csv")).to be(true)
  end

  after do
    SubjectReduction.delete_all
  end
end
