require 'spec_helper'

describe Effects::ExternalWithBasicAuth do
  # let(:subject) { create(:subject) }
  # let(:reduction) { create(:subject_reduction, reducer_key: "key", subject: subject, data: {}) }
  # let(:url) { "https://example.org/post/reduction/here" }
  # let(:effect) { described_class.new(url: url, reducer_key: "key") }

  # before do
  #   stub_request(:post, url).to_return(status: 200, headers: {})
  # end

  # it 'sends the reductions to the external API' do
  #   effect.perform(reduction.workflow_id, reduction.subject_id)
  #   expect(a_request(:post, url).with(body: reduction.prepare.to_json))
  #     .to have_been_made.once
  # end

  # it 'raises an error if more than one reduction is matched' do
  #   new_reduction = create(:subject_reduction, reducible: reduction.reducible, subgroup: "lol", reducer_key: "key", subject: subject, data: {})

  #   expect do
  #     effect.perform(reduction.workflow_id, reduction.subject_id)
  #   end.to raise_error(Effects::External::ExternalEffectFailed)
  # end

  # it 'raises an error if the post fails' do
  #   stub_request(:post, url).to_return(status: 500, headers: {})

  #   expect do
  #     effect.perform(reduction.workflow_id, reduction.subject_id)
  #   end.to raise_error(Effects::External::ExternalEffectFailed)
  # end

  # describe 'validations' do
  #   it 'is not valid with a non-https url' do
  #     effect = described_class.new(url: "http://foo.com")
  #     expect(effect).not_to be_valid
  #   end

  #   it 'is not valid with some strange url' do
  #     effect = described_class.new(url: "https:\\foo+3")
  #     expect(effect).not_to be_valid
  #   end

  #   it 'raises an error if no key is specified' do
  #     effect = described_class.new(url: url)

  #     expect do
  #       effect.perform(reduction.workflow_id, reduction.subject_id)
  #     end.to raise_error(Effects::External::InvalidConfiguration)
  #   end

  #   it 'does not care about symbol keys' do
  #     effect = described_class.new("url": "https://www.google.com")
  #     expect(effect.url).not_to be(nil)
  #     effect = described_class.new(url: "https://www.google.com")
  #     expect(effect.url).not_to be(nil)
  #   end

  #   it 'does not post if no url is configured' do
  #     effect = described_class.new(url: nil)

  #     expect do
  #       effect.perform(reduction.workflow_id, reduction.subject_id)
  #     end.to raise_error(Effects::External::InvalidConfiguration)
  #   end
  # end
end
