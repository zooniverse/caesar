describe RunRules do
  let(:workflow_id) { 1 }
  let(:subject_id) { 1 }

  it 'applies the rules to the merged set of reductions' do
    Reduction.create!(workflow_id: workflow_id, subject_id: subject_id, reducer_id: 1, data: {a: 1})
    Reduction.create!(workflow_id: workflow_id, subject_id: subject_id, reducer_id: 2, data: {b: 2})
    Reduction.create!(workflow_id: workflow_id, subject_id: subject_id, reducer_id: 3, data: {c: 3})

    rules = double("workflow rules", apply: nil)
    workflow = instance_double(Workflow, id: workflow_id, rules: rules)

    described_class.new(workflow, subject_id).perform

    expect(rules).to have_received(:apply).with("a" => 1, "b" => 2, "c" => 3).once
  end
end
