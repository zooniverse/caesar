describe Effects::RetireSubject do
  let(:workflow_id) { 10 }
  let(:subject_id) { 20}

  let(:panoptes) { double("PanoptesAdapter", retire_subject: true) }
  let(:effect) { described_class.new("reason" => "blank") }

  before do
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  it 'retires the given subject at panoptes' do
    effect.perform(workflow_id, subject_id)
    expect(panoptes).to have_received(:retire_subject).with(workflow_id, subject_id, reason: "blank")
  end

  it 'has initial stoplight_color of green' do
    effect.perform(workflow_id, subject_id)
    expect(effect.stoplight_color).to eq(Stoplight::Color::GREEN)
  end

  it 'defaults to a reason of "other"' do
    retire_subject = described_class.new
    retire_subject.perform(workflow_id, subject_id)
    expect(panoptes).to have_received(:retire_subject).with(workflow_id, subject_id, reason: "other")
  end

  describe 'failure' do
    it 'does not attempt the call on repeated failures' do
      allow(panoptes).to receive(:retire_subject)
        .and_raise(Panoptes::Client::ServerError.new('Another error'))
      3.times do
        expect { effect.perform(workflow_id, subject_id) }
          .to raise_error(Panoptes::Client::ServerError)
      end
      expect { effect.perform(workflow_id, subject_id) }
        .to raise_error(Stoplight::Error::RedLight)

      expect(effect.stoplight_color).to eq(Stoplight::Color::RED)
    end
  end
end
