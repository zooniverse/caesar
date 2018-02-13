require 'rails_helper'

RSpec.describe UserRuleEffect, type: :model do
  describe 'validations' do
    it 'is invalid when config is wrong' do
      rule_effect = build :user_rule_effect, action: :promote_user, config: {}
      expect(rule_effect).not_to be_valid
    end

    it 'is valid when the config is okay' do
      rule = build :user_rule
      rule_effect = rule.user_rule_effects.build action: :promote_user, config: { workflow_id: 1234}
      expect(rule_effect).to be_valid
    end
  end
end
