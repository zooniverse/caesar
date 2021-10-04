require 'spec_helper'

RSpec.describe CreateExtractsWorker, type: :worker do
  let(:project) { create :project }
  let(:workflow) { create :workflow, project_id: project.id }
  let(:source_url) { 'https://example.org/file.csv' }
  let(:csv_file) do
    StringIO.new <<~CSV
      extractor_key,subject_id,data
      alice,1,{a: foo}
      complete,1,{a: foo}
    CSV
  end

  before do
    allow(UrlDownloader).to receive(:stream).with(source_url).and_yield(csv_file)
  end

  describe '#perform' do
    it 'creates the extracts from csv' do
      described_class.new.perform(source_url, workflow.id)
      expect(Extract.count).to eq(2)
    end
  end
end
