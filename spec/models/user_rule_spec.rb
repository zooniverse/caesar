require 'rails_helper'

RSpec.describe UserRule, type: :model do
  let(:workflow) { create(:workflow) }
  let(:subject) { create(:subject) }
  let(:user_rule_effect) { build(:user_rule_effect) }

  describe 'validation' do
    it 'has error when condition is not supported' do
      rule = build :user_rule, condition: ["unknown_operation", 1, 2, 3]
      expect(rule).not_to be_valid
    end
  end

  context 'if the condition is true' do
    it 'performs all the effects' do
      rule = build :user_rule, workflow: workflow, condition: ["const", true], id: 123
      rule_effect = rule.user_rule_effects.build(action: :promote_user)

      allow(rule_effect).to receive(:prepare).and_call_original

      rule.process(subject.id, {})
      expect(rule_effect).to have_received(:prepare).with(123, workflow.id, subject.id).once
      expect(PerformUserActionWorker.jobs.size).to eq(1)
    end
  end
end
