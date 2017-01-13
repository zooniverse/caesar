require 'spec_helper'

describe Rules::Rule do
  let(:workflow) { double("Workflow") }
  let(:subject) { double("Subject") }
  let(:effect) { double(perform: nil) }

  context 'if the condition is true' do
    it 'performs all the effects' do
      condition = Conditions::Constant.new(true)
      rule = described_class.new(condition, [effect])
      rule.process(workflow, subject, {})
      expect(effect).to have_received(:perform).with(workflow, subject).once
    end
  end
end
