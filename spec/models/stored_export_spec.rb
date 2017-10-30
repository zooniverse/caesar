require 'rails_helper'

describe StoredExport do
  subject(:stored_export) { described_class.new("foo.csv") }

  describe '#upload_path' do
    it 'sets to downloadable path' do
      path = stored_export.send(:upload_path)
      expect(path).to eq("data-exports.zooniverse.org/caesar/foo.csv")
    end
  end

  describe '#content_disposition' do
    it 'is set to attachment with correct filename' do
      content_disposition = stored_export.send(:content_disposition)
      expect(content_disposition).to eq("attachment; filename=\"foo.csv\"")
    end
  end
end
