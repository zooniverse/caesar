require 'spec_helper'

describe Exporters::CsvExtractExporter do
  let(:workflow) { create :workflow }
  let(:subject) { Subject.create! }

  let(:exporter){ described_class.new }
  let(:workflow_id){ 1234 }
  let(:sample){
    Extract.new(
      extractor_id: "x",
      classification_id: 1236,
      classification_at: DateTime.now,
      workflow_id: workflow.id,
      subject_id: subject.id,
      data: {"key1" => "val1", "key2" => "val2" }
    )
  }

  before do
    if File.exist?"tmp/extracts_#{workflow.id}.csv"
      File.delete("tmp/extracts_#{workflow.id}.csv")
    end

    Extract.new(
      extractor_id: "x",
      classification_id: 1234,
      classification_at: DateTime.now,
      workflow_id: workflow.id,
      subject_id: Subject.create!.id,
      data: {"key1" => "val1"}
    ).save
    Extract.new(
      extractor_id: "x",
      classification_id: 1235,
      classification_at: DateTime.now,
      workflow_id: workflow.id,
      subject_id: Subject.create!.id,
      data: {"key2" => "val2"}
    ).save
    sample.save
    Extract.new(
      extractor_id: "x",
      classification_id: 1237,
      classification_at: DateTime.now,
      workflow_id: workflow.id,
      subject_id: Subject.create!.id,
      data: {"key1" => "val1", "key3" => "val3" }
    ).save
    Extract.new(
      extractor_id: "x",
      classification_id: 1238,
      classification_at: DateTime.now,
      workflow_id: create(:workflow).id,
      subject_id: Subject.create!.id,
      data: {"key4" => "val4"}
    ).save
  end

  it 'should give the right header row for the csv' do
    keys = exporter.get_csv_headers
    expect(keys).to include("id")
    expect(keys).to include("extractor_id")
    expect(keys).to include("classification_id")
    expect(keys).not_to include("data")
    expect(keys).not_to include("sdfjkasdfjk")
    expect(keys).to include("data.key1")
    expect(keys).not_to include("key1")
    expect(keys).to include("data.key2")
    expect(keys).to include("data.key3")
    expect(keys).not_to include("data.key4")
  end

  it 'should create the right file' do
    exporter.dump
    expect(File.exist?("tmp/extracts_#{workflow_id}.csv")).to be(true)
  end

  it 'should build the rows properly' do
    row = exporter.extract_row(sample)

    expect(row).to include("x")
    expect(row).to include("val1")
    expect(row).to include("val2")
    expect(row).to include("")
    expect(row).not_to include("val3")
    expect(row).to include(workflow.id)
  end
end
