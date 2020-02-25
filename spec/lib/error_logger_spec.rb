# frozen_string_literal: true
require 'spec_helper'

describe ErrorLogger do
  describe '.report' do
    let(:exception) { Exception.new('testing exception') }

    it 'calls raven (sentry) to log the error' do
      allow(Raven).to receive(:capture_exception)
      ErrorLogger.report(exception)
      expect(Raven).to have_received(:capture_exception).with(exception)
    end
  end
end
