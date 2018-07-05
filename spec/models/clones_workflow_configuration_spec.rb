require 'spec_helper'

describe ClonesWorkflowConfiguration do
  let(:workflow) { create :workflow }
  let(:destination) { create :workflow }
  let(:copier) { described_class.new(workflow, destination) }

  it 'copies extractors' do
    create :external_extractor, key: 'ext', workflow: workflow
    create :survey_extractor, key: 'surv', workflow: workflow

    copier.copy

    expect(destination.extractors.count).to eq(2)
  end

  it 'copies reducers' do
    create :external_reducer, key: 'ext', reducible: workflow
    create :stats_reducer, key: 'stats', reducible: workflow

    copier.copy

    expect(destination.reducers.count).to eq(2)
  end

  it 'copies rules' do
    rule = create :subject_rule, workflow: workflow
    create :subject_rule_effect, subject_rule: rule

    copier.copy

    expect(destination.subject_rules.count).to eq(1)
    expect(destination.subject_rules.first.subject_rule_effects.first.action).to eq("retire_subject")
  end
end
