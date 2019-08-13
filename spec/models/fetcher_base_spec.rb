require 'spec_helper'

describe FetcherBase do
  it 'sets the query correctly' do
    f = described_class.new user_id: 1234

    expect(f.query).to eq(user_id: 1234)
  end

  it 'sets the topic correctly' do
    f = described_class.new({})

    f.for! :reduce_by_subject
    expect(f.fetch_by_subject?).to be_truthy

    f.for! :reduce_by_user
    expect(f.fetch_by_user?).to be_truthy

    expect do
      f.for! :some_other_string
    end.to raise_error(ArgumentError)
  end
end