require 'spec_helper'

describe DataRequestWorker do
  let(:worker) { described_class.new }

  let(:stored_export) { double("StoredExport", "download_url" => "hi", "upload" => nil)}

  let(:project) { create :project }

  let(:workflow) { create :workflow }

  describe 'for workflows' do
    let(:workflow_request) do
      DataRequest.new(
        user_id: nil,
        exportable: workflow,
        subgroup: nil,
        requested_data: DataRequest.requested_data[:extracts]
      )
    end

    let(:workflow_request_id) do
      workflow_request.id
    end

    before(:each) do
      allow(StoredExport).to receive(:new).and_return(stored_export)
      workflow_request.status = DataRequest.statuses[:pending]
      workflow_request.save!
    end

    describe '#perform' do
      before do
        create :extract, workflow_id: workflow.id, data: { 'foo' => 'bar' }
      end

      it 'performs the export' do
        worker.perform(workflow_request_id)
        expect(DataRequest.find(workflow_request_id).complete?).to be(true)
      end

      it 'creates the file' do
        allow(File).to receive(:unlink).and_return(nil)
        worker.perform(workflow_request_id)
        expect(File.exist?("tmp/#{workflow_request_id}.csv")).to be(true)
        # cleanup the reuslting export file - this should really have been a tmp file
        ::File.unlink("tmp/#{workflow_request_id}.csv")
      end

      it 'exports the correct number of rows' do
        create :extract # create a fake workflow to ensure our scope filtering is correct
        worker.perform(workflow_request_id)
        expect(workflow_request.reload.records_count).to eq(1)
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
        create :subject_reduction, reducible: project

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

  describe 'for user reductions' do
    let(:workflow_request) do
      DataRequest.create(
        user_id: nil,
        exportable: workflow,
        subgroup: nil,
        requested_data: DataRequest.requested_data[:user_reductions]
      )
    end

    let(:workflow_request_id) do
      workflow_request.id
    end

    before(:each) do
      allow(StoredExport).to receive(:new).and_return(stored_export)
      workflow_request.pending!
    end

    describe '#perform' do
      it 'performs the export' do
        create :user_reduction, reducible: workflow

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

      it 'cancels the export' do
        create :user_reduction, user_id: 1234, reducible: workflow
        create :user_reduction, user_id: 2345, reducible: workflow
        create :user_reduction, user_id: 3456, reducible: workflow

        workflow_request.canceling!

        allow(worker).to receive(:progress_interval).and_return(2)
        worker.perform(workflow_request_id)
        expect(workflow_request.reload.canceled?).to be(true)
      end
    end

    after do
      DataRequest.find(workflow_request_id).delete
      if(File.exist?("tmp/#{workflow_request_id}.csv"))
        File.unlink "tmp/#{workflow_request_id}.csv"
      end
    end
  end
end
