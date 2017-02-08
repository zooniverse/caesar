describe RuleBindings do
  it 'looks up by reducer id and emitted key' do
    reductions = [
      Reduction.new(reducer_id: 'count', data: {"a" => 1}),
      Reduction.new(reducer_id: 'other', data: {"b" => 2})
    ]

    rule_bindings = described_class.new(reductions)
    expect(rule_bindings.fetch("count.a")).to eq(1)
    expect(rule_bindings.fetch("other.b")).to eq(2)
  end

  it 'works with overlapping data keys' do
    reductions = [
      Reduction.new(reducer_id: 'count', data: {"a" => 1}),
      Reduction.new(reducer_id: 'other', data: {"a" => 2})
    ]

    rule_bindings = described_class.new(reductions)
    expect(rule_bindings.fetch("count.a")).to eq(1)
    expect(rule_bindings.fetch("other.a")).to eq(2)
  end
end
