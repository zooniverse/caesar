require 'spec_helper'

describe Rules::Rule do
  let(:effect) { double(perform: nil) }

  context 'if the condition is true' do
    it 'performs all the effects' do
      condition = Conditions::Constant.new(true)
      rule = described_class.new(condition, [effect])
      rule.process({})
      expect(effect).to have_received(:perform).once
    end
  end
end
