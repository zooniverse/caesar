require 'rails_helper'

describe Uploader do
  let(:uploader) { described_class.new("/tmp/foo.csv") }

  describe '#upload_path' do
    it 'sets to downloadable path' do
      path = uploader.upload_path
      expect(path).to eq("data-exports.zooniverse.org/caesar/foo.csv")
    end

    it 'replaces multiple slashes' do
      uploader = described_class.new("/tmp/foo//bar///baz.csv")
      path = uploader.upload_path
      expect(path).to eq("data-exports.zooniverse.org/caesar/baz.csv")
    end
  end

  describe '#content_disposition' do
    it 'is set to attachment with correct filename' do
      expect(uploader.content_disposition).to eq("attachment; filename=\"foo.csv\"")
    end
  end
end
