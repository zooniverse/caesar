require 'spec_helper'

describe ApplicationStatus, sidekiq: :inline do
  subject(:status) { described_class.new }

  it 'counts the number of jobs in the sidekiq queueu' do
    allow_any_instance_of(Sidekiq::Queue).to receive(:size).and_return(12)
    expect(status.sidekiq_queue_size).to eq(12)
  end

  shared_examples_for "application status most recent model creation" do
    it 'returns the date of latest extract that was created' do
      date = Time.local(2017, 4, 1, 2, 5, 2)
      create(model_type, created_at: date)
      expect(status.public_send("newest_#{model_type}_date")).to eq(date)
    end

    it 'returns nil if no models in database' do
      expect(status.public_send("newest_#{model_type}_date")).to be_nil
    end
  end

  describe 'newest_extract_date' do
    it_behaves_like("application status most recent model creation") { let(:model_type) { :extract} }
  end

  describe 'newest_extract_date' do
    it_behaves_like("application status most recent model creation") { let(:model_type) { :reduction} }
  end

  describe 'newest_extract_date' do
    it_behaves_like("application status most recent model creation") { let(:model_type) { :action} }
  end
end
