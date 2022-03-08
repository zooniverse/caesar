require 'rails_helper'

RSpec.describe SubjectRuleEffect, type: :model do
  describe 'validations' do
    let(:subject_rule) { build :subject_rule }
    let(:subject_rule_effect) do
      build :subject_rule_effect, subject_rule: subject_rule, action: :retire_subject, config: { 'reason' => 'classification_count' }
    end

    it 'is valid by default' do
      expect(subject_rule_effect).to be_valid
    end

    it 'is invalid when config is incorrectly setup' do
      subject_rule_effect.config = { 'reason' => '' }
      expect(subject_rule_effect).not_to be_valid
    end

    describe 'external_with_basic_auth action' do
      let(:config) { { url: 'https://example.com', reducer_key: 'my_reducer', username: '', password: '' } }
      let(:subject_rule_effect) do
        build :subject_rule_effect, subject_rule: subject_rule, action: :external_with_basic_auth, config: config
      end

      it 'allows external_with_basic_auth action type' do
        expect(subject_rule_effect).to be_valid
      end
    end
  end
end
