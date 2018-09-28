require 'spec_helper'

describe Effects::External do
  let(:reduction) { create(:subject_reduction, reducer_key: "key") }
  let(:url) { "https://example.org/post/reduction/here" }
  let(:effect) { described_class.new(url: url, reducer_key: "key") }

  before do
    stub_request(:post, url).to_return(status: 200, headers: {})
  end

  it 'sends the reductions to the external API' do
    effect.perform(reduction.workflow_id, reduction.subject_id)
    expect(a_request(:post, url).with(body: [reduction].to_json))
      .to have_been_made.once
  end

  it 'does not include reductions that do not match the reducer key' do
    effect = described_class.new(url: url, reducer_key: "yarp")
    effect.perform(reduction.workflow_id, reduction.subject_id)

    expect(a_request(:post, url).with(body: [].to_json))
      .to have_been_made.once
  end

  it 'includes all reductions if no key is specified' do
    effect = described_class.new(url: url)
    effect.perform(reduction.workflow_id, reduction.subject_id)

    expect(a_request(:post, url).with(body: [reduction].to_json))
      .to have_been_made.once
  end

  it 'does not post if no url is configured' do
    effect = described_class.new(url: nil)

    expect do
      effect.perform(reduction.workflow_id, reduction.subject_id)
    end.to raise_error(StandardError)
  end

  describe 'validations' do
    it 'is not valid with a non-https url' do
      effect = described_class.new(url: "http://foo.com")
      expect(effect).not_to be_valid
    end

    it 'is not valid with some strange url' do
      effect = described_class.new(url: "https:\\foo+3")
      expect(effect).not_to be_valid
    end
  end
end
