require 'spec_helper'

describe Workflow::ConvertLegacyExtractorsConfig do
  let(:workflow) { create :workflow }

  it 'updates config for existing extractors' do
    extractor = create :external_extractor, key: 'blank', workflow: workflow

    described_class.new(workflow).update(
      "blank" => {"a" => "b", "minimum_version" => "4.1"}
    )

    expect(extractor.reload.config).to eq("a" => "b")
    expect(extractor.reload.minimum_workflow_version).to eq("4.1")
  end

  it 'adds new extractors' do
    expect {
      described_class.new(workflow).update("blank" => {"type" => "blank", "a" => "b"})
    }.to change { workflow.extractors.count }.from(0).to(1)
    expect(workflow.extractors.first.config).to eq("a" => "b")
  end

  it 'removes extractors that are no longer mentioned' do
    create :external_extractor, key: 'blank', workflow: workflow
    create :external_extractor, key: 'old', workflow: workflow

    expect {
      described_class.new(workflow).update("blank" => {})
    }.to change { workflow.extractors.count }.from(2).to(1)
  end

  it 'allows removing all extractors' do
    create :external_extractor, key: 'blank', workflow: workflow
    create :external_extractor, key: 'old', workflow: workflow

    expect {
      described_class.new(workflow).update({})
    }.to change { workflow.extractors.count }.from(2).to(0)
  end

  it 'does nothing if no config given' do
    create :external_extractor, key: 'blank', workflow: workflow

    expect {
      described_class.new(workflow).update(nil)
    }.not_to change { workflow.extractors.count }
  end
end
