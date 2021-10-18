# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ImportMLDataWorker, type: :worker do
  let(:project) { create :project }
  let(:workflow) { create :workflow, project_id: project.id }
  let(:source_url) { 'https://example.org/file.csv' }
  let(:subject) { create :subject, id: 31 }
  let(:extractor_key1) { 'alice' }
  let(:extractor_key2) { 'complete' }
  let(:csv_file) do
    StringIO.new <<~CSV
      extractor_key,subject_id,data
      #{extractor_key1},#{subject.id},{a: foo}
      #{extractor_key2},#{subject.id},{b: foo2}
    CSV
  end

  before do
    allow(UrlDownloader).to receive(:stream).with(source_url).and_yield(csv_file)
  end

  describe '#perform' do
    it 'creates the extracts from csv' do
      described_class.new.perform(source_url, workflow.id)
      expect(Extract.count).to eq(2)
      extract1 = Extract.find_by extractor_key: extractor_key1
      extract2 = Extract.find_by extractor_key: extractor_key2

      expect(extract1).not_to be(nil)
      expect(extract1.data).to eq('{a: foo}')
      expect(extract1.machine_data).to be(true)
      expect(extract1.subject_id).to be(31)

      expect(extract2).not_to be(nil)
      expect(extract2.data).to eq('{b: foo2}')
      expect(extract2.machine_data).to be(true)
      expect(extract2.subject_id).to be(31)
    end

    it 'upserts subjects if subject not in caesar db' do
      new_subj_id = 29
      csv_file2 = StringIO.new <<~CSV
        extractor_key,subject_id,data
        #{extractor_key1},#{new_subj_id},{a: foo}
      CSV
      allow(UrlDownloader).to receive(:stream).with(source_url).and_yield(csv_file2)
      described_class.new.perform(source_url, workflow.id)

      expect(Subject.find(29)).not_to be(nil)
      expect(Subject.find(29).metadata).to eq({})
    end

    it 'does not run any reducers if there are no reducers' do
      expect_any_instance_of(IsReducible).not_to receive(:rerun_reducers)
      described_class.new.perform(source_url, workflow.id)
    end

    it 'runs any workflow reducers' do
      workflow2 = create :workflow, reducers_count: 1, project_id: project.id
      expect_any_instance_of(IsReducible).to receive(:rerun_reducers)
      described_class.new.perform(source_url, workflow2.id)
    end

    it 'runs any project reducers' do
      project2 = create :project, reducers_count: 1
      workflow2 = create :workflow, project_id: project2.id
      expect_any_instance_of(IsReducible).to receive(:rerun_reducers)
      described_class.new.perform(source_url, workflow2.id)
    end
  end
end
