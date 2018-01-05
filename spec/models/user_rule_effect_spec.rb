require 'rails_helper'

RSpec.describe UserRuleEffect, type: :model do
  describe 'validations' do
    it 'is invalid when config is wrong' do
      rule_effect = build :user_rule_effect, action: :promote_user, config: {}
      expect(rule_effect).not_to be_valid
    end
  end
end
