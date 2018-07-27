require 'rails_helper'

RSpec.describe ReduceWorker, type: :worker do
  let(:reducible) { create :project }
  let(:subject) { create :subject }
  let(:reducer) { create(:stats_reducer, key: 's', reducible: reducible) }
  let(:pipeline) { reducible.classification_pipeline }

  it "calls #reduce on the correct pipeline" do
    expect_any_instance_of(ClassificationPipeline).to receive(:reduce).once.with(reducible.id, subject.id, nil, [])
    described_class.new.perform(reducible.id, reducible.class.to_s, subject.id, nil)
  end
end
