require 'rails_helper'

RSpec.describe SubjectRuleEffect, type: :model do
  describe 'validations' do
    it 'is invalid when config is wrong' do
      rule_effect = build :subject_rule_effect, action: :retire_subject, config: {}
      expect(rule_effect).not_to be_valid
    end
  end
end
