require 'spec_helper'

describe Workflow::ConvertLegacyReducersConfig do
  let(:workflow) { create :workflow }

  it 'updates config for existing reducers' do
    reducer = create :stats_reducer, key: 'stat', reducible: workflow

    described_class.new(workflow).update(
      "stat" => {"a" => "b", "filters" => {"from" => 1}, "group_by" => "s.LK"}
    )

    expect(reducer.reload.config).to eq("a" => "b")
    expect(reducer.reload.filters).to eq("from" => 1)
  end

  it 'adds new reducers' do
    expect {
      described_class.new(workflow).update("stat" => {"type" => "stats", "a" => "b"})
    }.to change { workflow.reducers.count }.from(0).to(1)
    expect(workflow.reducers.first.config).to eq("a" => "b")
  end

  it 'removes reducers that are no longer mentioned' do
    create :stats_reducer, key: 'stat', reducible: workflow
    create :stats_reducer, key: 'old', reducible: workflow

    expect {
      described_class.new(workflow).update("stat" => {})
    }.to change { workflow.reducers.count }.from(2).to(1)
  end

  it 'allows removing all reducers' do
    create :stats_reducer, key: 'stat', reducible: workflow
    create :stats_reducer, key: 'old', reducible: workflow

    expect {
      described_class.new(workflow).update({})
    }.to change { workflow.reducers.count }.from(2).to(0)
  end

  it 'does nothing if no config given' do
    create :stats_reducer, key: 'stat', reducible: workflow

    expect {
      described_class.new(workflow).update(nil)
    }.not_to change { workflow.reducers.count }
  end
end
