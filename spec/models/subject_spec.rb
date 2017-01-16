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
end
