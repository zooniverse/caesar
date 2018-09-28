require 'spec_helper'

describe Subject, type: :model do
  describe '.update_cache' do
    it 'updates the cached metadata for a subject' do
      expect do
        described_class.update_cache("id" => 1, "metadata" => {"biome" => "ocean"})
      end.to change { Subject.count }.from(0).to(1)

      expect(Subject.first.metadata).to eq("biome" => "ocean")
    end
  end

  describe '.maybe_create_subject' do
    let(:panoptes_yes) { double("PanoptesAdapter", subject_in_project?: { "id" => "1234", "metadata" => { "foo" => "bar" } }) }
    let(:panoptes_no) { double("PanoptesAdapter", subject_in_project?: nil) }

    it 'does not create a subject when one already exists' do
      subject = create :subject
      expect(Subject.maybe_create_subject subject.id, nil).to be(nil)
      expect(panoptes).not_to have_received(:subject_in_project?)
    end

    it 'creates a subject if allowed' do
      allow(Effects).to receive(:panoptes).and_return(panoptes_yes)
      wf = create :workflow

      expect(Subject.maybe_create_subject 1234, wf).not_to be(nil)
      expect(Subject.exists? 1234).to be(true)
      expect(Subject.find(1234).metadata['foo']).to eq('bar')
    end

    it 'does not create a subject if not allowed' do
      allow(Effects).to receive(:panoptes).and_return(panoptes_no)
      wf = create :workflow

      expect(Subject.maybe_create_subject 1234, wf).to be(nil)
      expect(Subject.exists? 1234).to be(false)
    end
  end
end
