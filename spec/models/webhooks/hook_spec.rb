require 'spec_helper'

describe Webhooks::Hook do
  let(:configured_hook) { described_class.new(
    "http://example.org",
    ["classification", "reduction"]
  ) }

  describe '#process' do
    it 'notifies of all subscribed events' do
      expect do
        configured_hook.process("classification", {})
        configured_hook.process("reduction", {})
      end.to change(NotifyWebhookWorker.jobs, :size).by(2)
    end

    it 'only notifies of subscribed events' do
      expect do
        configured_hook.process("extraction", {})
      end.not_to change(NotifyWebhookWorker.jobs, :size)
    end
  end

  describe '#configured?' do
    it 'knows when things are not configured' do
      expect(described_class.new(nil, nil).configured?).to be(false)
      expect(described_class.new("", nil).configured?).to be(false)
    end

    it 'knows when things are configured' do
      expect(described_class.new("http://example.org", nil).configured?).to be(true)
      expect(described_class.new("http://example.org", []).configured?).to be(true)
      expect(described_class.new("http://example.org", ["test"]).configured?).to be(true)
    end
  end

  describe '#subscribed?' do
    it 'knows when things are subscribed' do
      expect(described_class.new("http://example.org", nil).subscribed? "test").to be(true)
      expect(described_class.new("http://example.org", []).subscribed? "test").to be(true)
      expect(described_class.new("http://example.org", ["test"]).subscribed? "test").to be(true)
      expect(described_class.new("http://example.org", ["foo","test"]).subscribed? "test").to be(true)
    end

    it 'knows when things are not subscribed' do
      expect(described_class.new("http://example.org", ["foo"]).subscribed? "test").to be(false)
    end
  end

end
