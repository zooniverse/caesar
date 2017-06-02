require 'spec_helper'

describe Webhooks::Engine do
  let(:nil_engine) { described_class.new(nil)}

  let(:zero_engine) { described_class.new([]) }

  let(:one_engine) { described_class.new([{
   "endpoint" => "http://example.org",
   "events" => ["new_extraction"]
  }]) }

  let(:two_engine) { described_class.new([{
    "endpoint" => "http://example.org",
    "events" => ["new_classification"]
  }, {
    "endpoint" => "http://example.org",
    "events" => ["new_reduction"]
  }]) }

  describe '#initialize' do
    it 'builds itself correctly' do
      expect(nil_engine.size).to equal(0)
      expect(zero_engine.size).to equal(0)
      expect(one_engine.size).to equal(1)
      expect(two_engine.size).to equal(2)
    end
  end

  describe '#process' do
    it 'queues up notification jobs correctly' do

      expect do
        two_engine.process(:new_classification, {})
        two_engine.process(:new_classification, {})
        two_engine.process(:new_extraction, {})
        two_engine.process(:new_reduction, {})
      end.to change(NotifyWebhookWorker.jobs, :size).by(3)
    end
  end

end
