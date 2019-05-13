describe RuleBindings do
  let(:subject) { build_stubbed(:subject) }

  it 'looks up by reducer id and emitted key' do
    reductions = [
      SubjectReduction.new(reducer_key: 'count', data: {"a" => 1}),
      SubjectReduction.new(reducer_key: 'other', data: {"b" => 2})
    ]

    rule_bindings = described_class.new(reductions, Subject.new)
    expect(rule_bindings.fetch("count.a")).to eq(1)
    expect(rule_bindings.fetch("other.b")).to eq(2)
  end

  it 'exposes subject id' do
    reductions = []
    subject = build_stubbed(:subject, id: 1234, metadata: {})

    rule_bindings = described_class.new(reductions, subject)
    expect(rule_bindings.fetch("subject.zooniverse_subject_id")).to eq(1234)
  end

  it 'exposes subject metadata' do
    reductions = []
    subject = build_stubbed(:subject, metadata: {"region" => "oxford"})

    rule_bindings = described_class.new(reductions, subject)
    expect(rule_bindings.fetch("subject.region")).to eq("oxford")
  end

  it 'returns default when reducer has not produced reduction yet' do
    reductions = []
    rule_bindings = described_class.new(reductions, subject)
    default_value = double
    expect(rule_bindings.fetch("count.a", default_value)).to eq(default_value)
  end

  it 'handles absent keys' do
    reductions = [
      SubjectReduction.new(reducer_key: 'count', data: {"a" => 1}),
      SubjectReduction.new(reducer_key: 'other', data: {"b" => 2})
    ]

    unexpected = double

    rule_bindings = described_class.new(reductions, subject)
    expect(rule_bindings.fetch("count.a")).to eq(1)
    expect(rule_bindings.fetch("count.b")).to be(nil)
    expect(rule_bindings.fetch("count.b",unexpected)).to eq(unexpected)
  end

  it 'works with overlapping data keys' do
    reductions = [
      SubjectReduction.new(reducer_key: 'count', data: {"a" => 1}),
      SubjectReduction.new(reducer_key: 'other', data: {"a" => 2})
    ]

    rule_bindings = described_class.new(reductions, subject)
    expect(rule_bindings.fetch("count.a")).to eq(1)
    expect(rule_bindings.fetch("other.a")).to eq(2)
  end

  it 'returns the default if the resolved value is nil' do
    default = double
    reductions = [
      SubjectReduction.new(reducer_key: 'a', data: {"b" => nil})
    ]

    rule_bindings = described_class.new(reductions, nil)
    expect(rule_bindings.fetch('a.b', default)).to eq(default)
  end
end
