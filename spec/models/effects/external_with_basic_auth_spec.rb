require 'spec_helper'

describe Effects::ExternalWithBasicAuth do
  let(:subject) { create(:subject) }
  let(:reduction) { create(:subject_reduction, reducer_key: "key", subject: subject, data: {}) }
  let(:url) { 'https://example.org/post/reduction/here' }
  let(:username) { 'sloan-api' }
  let(:password) { 'sloan-api-password' }
  let(:effect_config) { { url: url, reducer_key: "key", username: username, password: password } }
  let(:effect) { described_class.new(effect_config) }

  before do
    stub_request(:post, url)
      .with(
        basic_auth: [username, password],
        headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
      )
      .to_return(status: 200, headers: {})
  end

  it 'sends the reductions to the external API' do
    effect.perform(reduction.workflow_id, reduction.subject_id)
    expect(
      a_request(:post, url).with(body: reduction.prepare.to_json)
    ).to have_been_made.once
  end

  it 'raises an error if more than one reduction is matched' do
    create(:subject_reduction, reducible: reduction.reducible, subgroup: 'lol', reducer_key: 'key', subject: subject, data: {})
    expect do
      effect.perform(reduction.workflow_id, reduction.subject_id)
    end.to raise_error(Effects::ExternalWithBasicAuth::ExternalEffectFailed)
  end

  it 'raises an error if the post fails' do
    stub_request(:post, url)
      .with(
        basic_auth: [username, password],
        headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
      )
      .to_return(status: 500, headers: {})

    expect do
      effect.perform(reduction.workflow_id, reduction.subject_id)
    end.to raise_error(Effects::ExternalWithBasicAuth::ExternalEffectFailed)
  end

  it 'does not post if no url is configured' do
    effect = described_class.new(url: nil)

    expect do
      effect.perform(reduction.workflow_id, reduction.subject_id)
    end.to raise_error(Effects::ExternalWithBasicAuth::InvalidConfiguration)
  end

  describe 'config' do
    it 'does not care about symbol keys' do
      effect = described_class.new("url": "https://www.google.com")
      expect(effect.url).not_to be(nil)
      effect = described_class.new(url: "https://www.google.com")
      expect(effect.url).not_to be(nil)
    end
  end

  describe 'validations' do
    it 'is invalid with a non-https url' do
      effect_config[:url] = 'http://foo.com'
      effect = described_class.new(effect_config)
      expect(effect).not_to be_valid
    end

    it 'is invalid with some strange url' do
      effect_config[:url] = 'https:\\foo+3'
      effect = described_class.new(effect_config)
      expect(effect).not_to be_valid
    end

    it 'raises an error if no key is specified' do
      effect = described_class.new(effect_config.except(:reducer_key))
      expect do
        effect.perform(reduction.workflow_id, reduction.subject_id)
      end.to raise_error(Effects::ExternalWithBasicAuth::InvalidConfiguration)
    end

    it 'raises an error if no username is specified' do
      effect = described_class.new(effect_config.except(:username))
      expect do
        effect.perform(reduction.workflow_id, reduction.subject_id)
      end.to raise_error(Effects::ExternalWithBasicAuth::InvalidConfiguration)
    end

    it 'raises an error if no password is specified' do
      effect = described_class.new(effect_config.except(:password))
      expect do
        effect.perform(reduction.workflow_id, reduction.subject_id)
      end.to raise_error(Effects::ExternalWithBasicAuth::InvalidConfiguration)
    end
  end
end
