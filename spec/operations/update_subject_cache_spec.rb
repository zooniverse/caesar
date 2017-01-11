require 'rails_helper'

RSpec.describe UpdateSubjectCache do
  it 'updates the cached metadata for a subject' do
    operation = described_class.new("id" => 1, "metadata" => {"biome" => "ocean"})
    operation.perform

    expect(Subject.count).to eq(1)
    expect(Subject.first.metadata).to eq("biome" => "ocean")
  end
end
