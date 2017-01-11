describe RunExtractors do
  let(:extractor)      { double("extractor", extract: nil) }
  let(:workflow)       { instance_double(Workflow, id: 1, extractors: {1 => extractor}) }
  let(:subject)        { instance_double(Subject, id: 1) }
  let(:classification) { instance_double("Classification", id: 1, subject_id: subject.id) }

  it 'applies the rules to the merged set of reductions' do
    allow(extractor).to receive(:extract).with(classification).and_return(a: 1)

    described_class.new(workflow, classification).perform

    expect(Extract.count).to eq(1)
    expect(Extract.first.data).to eq("a" => 1)
  end
end
