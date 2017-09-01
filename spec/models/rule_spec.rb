require 'rails_helper'

RSpec.describe Rule, type: :model do
  let(:workflow) { create(:workflow) }
  let(:subject) { create(:subject) }
  let(:rule_effect) { build(:rule_effect) }

  context 'if the condition is true' do
    it 'performs all the effects' do
      rule = build :rule, workflow: workflow, condition: ["const", true]
      rule_effect = rule.rule_effects.build(action: :retire_subject)

      allow(rule_effect).to receive(:prepare).and_call_original

      rule.process(workflow.id, subject.id, {})
      expect(rule_effect).to have_received(:prepare).with(workflow.id, subject.id).once
      expect(PerformActionWorker.jobs.size).to eq(1)
    end
  end
end
