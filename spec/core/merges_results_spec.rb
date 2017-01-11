describe MergesResults do
  it 'returns a merged hash' do
    merged = described_class.merge([{a: 1}, {b: 2}, {c: 3}])
    expect(merged).to eq(a: 1, b: 2, c: 3)
  end

  it 'raises if any of the hash uses a key that was already present' do
    expect { described_class.merge([{a: 1}, {b: 2}, {a: 3}]) }.to raise_error(MergesResults::OverlappingKeys)
  end
end
