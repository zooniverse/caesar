require 'spec_helper'
require 'uploader'

describe DataRequestWorker do
  let(:worker) { described_class.new }

  let(:uploader) { double("Uploader", "url" => "hi", "upload" => nil)}

  let(:workflow) { build :workflow }

  let(:request) do
    DataRequest.new(
      user_id: 1234,
      workflow: workflow,
      subgroup: nil,
      requested_data: DataRequest.requested_data[:extracts]
    )
  end

  let(:request_id) do
    request.id
  end

  before do
    allow(Uploader).to receive(:new).and_return(uploader)
    request.status = DataRequest.statuses[:pending]
    request.url = nil
    request.save!
  end

  describe '#perform' do
    it 'does the thing' do
      worker.perform(request_id)
      expect(DataRequest.find(request_id).complete?).to be(true)
    end

    it 'creates the file' do
      allow(File).to receive(:unlink).and_return(nil)
      worker.perform(request_id)
      expect(File.exist?("tmp/#{request_id}.csv")).to be(true)
    end

    it 'uploads the file' do
      worker.perform(request_id)
      expect(uploader).to have_received(:upload)
    end
  end

  after do
    DataRequest.delete_all
    if(File.exist?("tmp/#{request_id}.csv"))
      File.unlink "tmp/#{request_id}.csv"
    end
  end
end
