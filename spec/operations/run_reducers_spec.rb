describe RunReducers do
  let(:reducer)  { double("Reducer", reduce: nil) }
  let(:workflow) { instance_double(Workflow, id: 1, reducers: {1 => reducer}) }
  let(:subject)  { instance_double(Subject, id: 1) }

  before do
    Extract.create!(workflow_id: workflow.id, subject_id: subject.id, extractor_id: 1, data: {a: 1})
    Extract.create!(workflow_id: workflow.id, subject_id: subject.id, extractor_id: 2, data: {b: 2})
    Extract.create!(workflow_id: workflow.id, subject_id: subject.id, extractor_id: 3, data: {c: 3})
  end

  it 'applies the rules to the merged set of reductions' do
    allow(reducer).to receive(:reduce).with([{"a" => 1}, {"b" => 2}, {"c" => 3}]).and_return(reduced: true)

    described_class.new(workflow, subject.id).perform

    expect(Reduction.count).to eq(1)
    expect(Reduction.first.data).to eq("reduced" => true)
  end
end
