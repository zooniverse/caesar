require 'spec_helper'

describe DataRequestWorker do
  let(:worker) { described_class.new }

  let(:stored_export) { double("StoredExport", "download_url" => "hi", "upload" => nil)}

  let(:project) { create :project }

  let(:workflow) { create :workflow }

  describe 'for workflows' do
    before(:each) do
      allow(StoredExport).to receive(:new).and_return(stored_export)
      workflow_request.status = DataRequest.statuses[:pending]
      workflow_request.save!
    end

    let(:workflow_request) do
      DataRequest.new(
        user_id: 1234,
        exportable: workflow,
        subgroup: nil,
        requested_data: DataRequest.requested_data[:extracts]
      )
    end

    let(:workflow_request_id) do
      workflow_request.id
    end

    describe '#perform' do
      it 'performs the export' do
        worker.perform(workflow_request_id)
        expect(DataRequest.find(workflow_request_id).complete?).to be(true)
      end

      it 'creates the file' do
        allow(File).to receive(:unlink).and_return(nil)
        worker.perform(workflow_request_id)
        expect(File.exist?("tmp/#{workflow_request_id}.csv")).to be(true)
      end

      it 'uploads the file' do
        worker.perform(workflow_request_id)
        expect(stored_export).to have_received(:upload)
      end
    end

    after do
      DataRequest.find(workflow_request_id).delete
      if(File.exist?("tmp/#{workflow_request_id}.csv"))
        File.unlink "tmp/#{workflow_request_id}.csv"
      end
    end
  end

  describe 'for projects' do
    before(:each) do
      allow(StoredExport).to receive(:new).and_return(stored_export)
      project_request.status = DataRequest.statuses[:pending]
      project_request.save!
    end

    let(:project_request) do
      DataRequest.new(
        user_id: nil,
        exportable: project,
        subgroup: nil,
        requested_data: DataRequest.requested_data[:subject_reductions]
      )
    end

    let(:project_request_id) do
      project_request.id
    end

    describe '#perform' do
      it 'performs the export' do
        worker.perform(project_request_id)
        expect(DataRequest.find(project_request_id).complete?).to be(true)
      end

      it 'creates the file' do
        allow(File).to receive(:unlink).and_return(nil)
        worker.perform(project_request_id)
        expect(File.exist?("tmp/#{project_request_id}.csv")).to be(true)
      end

      it 'uploads the file' do
        worker.perform(project_request_id)
        expect(stored_export).to have_received(:upload)
      end
    end

    after do
      DataRequest.find(project_request_id).delete
      if(File.exist?("tmp/#{project_request_id}.csv"))
        File.unlink "tmp/#{project_request_id}.csv"
      end
    end
  end
end
