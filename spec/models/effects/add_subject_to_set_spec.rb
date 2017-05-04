require 'spec_helper'

describe Effects::AddSubjectToSet do
  let(:workflow_id) { 10 }
  let(:subject_id){ 20 }

  let(:panoptes) { double("PanoptesAdapter", add_subjects_to_subject_set: true) }

  before do
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  it 'adds the given subject to a given subject set' do
    add_to_set = described_class.new("subject_set_id" => 1234)
    add_to_set.perform(workflow_id, subject_id)
    expect(panoptes).to have_received(:add_subjects_to_subject_set)
      .with(1234, [20])
  end

  it 'knows when an exception is safe to ignore' do
    duplicate = { :errors => [{:message => "PG::UniqueViolation"}]}
    unexpected = { :errors => [{:message => "ActiveRecord::Error"}]}

    expect(described_class.was_duplicate(Panoptes::Client::ServerError.new(duplicate))).to be(true)
    expect(described_class.was_duplicate(Panoptes::Client::ServerError.new(unexpected))).to be(false)
  end

end
