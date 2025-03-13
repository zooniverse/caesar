require 'spec_helper'

describe Effects::AddSubjectToCollection do
  let(:workflow_id) { 10 }
  let(:subject_id){ 20 }
  let(:collection_id){ 1234 }

  let(:panoptes) { double("PanoptesAdapter", add_subjects_to_collection: true) }
  let(:effect) { described_class.new("collection_id" => collection_id) }

  before do
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  it 'adds the given subject to a given subject set' do
    effect.perform(workflow_id, subject_id)
    expect(panoptes).to have_received(:add_subjects_to_collection)
      .with(collection_id, [subject_id])
  end

  it 'propagates normal errors normally' do
    allow(panoptes).to receive(:add_subjects_to_collection)
      .and_raise(Panoptes::Client::ServerError.new('foo'))
    expect do
      effect.perform(workflow_id, subject_id)
    end.to raise_error(Panoptes::Client::ServerError)
  end

  describe 'failure' do
    it 'swallows error if subject is already in collection' do
      allow(panoptes).to receive(:add_subjects_to_collection).and_raise(Panoptes::Client::ServerError.new('Subject is already in the collection'))
      effect.perform(workflow_id, subject_id)
    end

    it 'does not attempt the call on repeated failures' do
      allow(panoptes).to receive(:add_subjects_to_collection)
        .and_raise(Panoptes::Client::ServerError.new('Another error'))

      3.times do
        expect { effect.perform(workflow_id, subject_id) }
          .to raise_error(Panoptes::Client::ServerError)
      end

      expect { effect.perform(workflow_id, subject_id) }
        .to raise_error(Stoplight::Error::RedLight)
    end
  end
end
