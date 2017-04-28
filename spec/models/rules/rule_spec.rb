require 'spec_helper'

describe Rules::Rule do
  let(:workflow) { double("Workflow") }
  let(:subject) { double("Subject") }
  let(:effect) { double(prepare: double("Action", id: 132)) }

  context 'if the condition is true' do
    it 'performs all the effects' do
      condition = Conditions::Constant.new(true)
      rule = described_class.new(condition, [effect])
      rule.process(workflow, subject, {})
      expect(effect).to have_received(:prepare).with(workflow, subject).once
      expect(PerformActionWorker.jobs.size).to eq(1)
    end
  end
end
