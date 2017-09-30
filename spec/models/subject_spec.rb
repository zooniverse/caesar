require 'rails_helper'

RSpec.describe Subject, type: :model do
  describe '.update_cache' do
    it 'updates the cached metadata for a subject' do
      expect do
        described_class.update_cache("id" => 1, "metadata" => {"biome" => "ocean"})
      end.to change { Subject.count }.from(0).to(1)

      expect(Subject.first.metadata).to eq("biome" => "ocean")
    end
  end

  describe '#thumbnail' do
    it 'returns nil if there are no locations' do
      subject = described_class.new(locations: [])
      expect(subject.thumbnail).to eq(nil)
    end

    it 'returns a jpeg url' do
      subject = described_class.new(locations: [
        {"image/jpeg" => "one"}
      ])

      expect(subject.thumbnail).to eq("one")
    end

    it 'returns nil if no location has an image mime' do
      subject = described_class.new(locations: [
        {"audio/mpeg" => ""},
        {"video/h264" => ""}
      ])

      expect(subject.thumbnail).to eq(nil)
    end
  end
end
