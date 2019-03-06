require 'spec_helper'

describe Reducers::AggregationReducers::RectangleReducer do
  let(:workflow){ create :workflow }
  let(:subject_reduction){ create :subject_reduction, reducible_type: 'Workflow', reducible_id: workflow.id }

  it 'is valid by default' do
    expect(described_class.new(key: 'ext')).to be_valid
  end

  describe 'validates the shapes of parameters' do
    it 'validates eps' do
      expect(described_class.new(key: 'ext', eps: 'foo')).not_to be_valid
      expect(described_class.new(key: 'ext', eps: 7)).to be_valid
      expect(described_class.new(key: 'ext', eps: nil).eps).to eq(5.0)
    end

    it 'validates min_samples' do
      expect(described_class.new(key: 'ext', min_samples: 'foo')).not_to be_valid
      expect(described_class.new(key: 'ext', min_samples: 7)).to be_valid
      expect(described_class.new(key: 'ext', min_samples: nil).min_samples).to eq(3)
    end

    it 'validates metric' do
      expect(described_class.new(key: 'ext', metric: 'blah')).not_to be_valid
      expect(described_class.new(key: 'ext', metric: 7)).not_to be_valid
      expect(described_class.new(key: 'ext', metric: 'cosine')).to be_valid
      expect(described_class.new(key: 'ext', metric: nil).metric).to eq('euclidean')
    end

    it 'validates algorithms' do
      expect(described_class.new(key: 'ext', algorithm: 'blah')).not_to be_valid
      expect(described_class.new(key: 'ext', algorithm: 7)).not_to be_valid
      expect(described_class.new(key: 'ext', algorithm: 'kd_tree')).to be_valid
      expect(described_class.new(key: 'ext', algorithm: nil).algorithm).to eq('auto')
    end

    it 'validates leaf_size' do
      expect(described_class.new(key: 'ext', leaf_size: 'blah')).not_to be_valid
      expect(described_class.new(key: 'ext', leaf_size: 7)).to be_valid
      expect(described_class.new(key: 'ext', leaf_size: nil).leaf_size).to eq(30)
    end

    it 'validates p' do
      expect(described_class.new(key: 'ext', p: 'blah')).not_to be_valid
      expect(described_class.new(key: 'ext', p: 7)).to be_valid
      expect(described_class.new(key: 'ext', p: nil).p).to be_nil
    end
  end

  describe 'builds urls correctly' do
    it 'builds the default URL' do
      expect(described_class.new(key: 'ext', reducible: workflow).url).to eq(
        'https://aggregation-caesar.zooniverse.org/reducers/rectangle_reducer?eps=5.0&min_samples=3&metric=euclidean&algorithm=auto&leaf_size=30'
      )
    end

    it 'uses all custom values' do
      reducer = described_class.new(
        key: 'ext',
        reducible: workflow,
        config: {
          eps: 8.0,
          min_samples: 4,
          metric: 'minkowski',
          leaf_size: 25,
          p: 2
        }
      )

      expect(reducer.url).to eq(
        'https://aggregation-caesar.zooniverse.org/reducers/rectangle_reducer?eps=8.0&min_samples=4&metric=minkowski&algorithm=auto&leaf_size=25&p=2'
      )
    end
  end

  it 'sends the request correctly' do
    stub_request(:post, 'https://aggregation-caesar.zooniverse.org/reducers/rectangle_reducer?eps=5.0&min_samples=3&metric=euclidean&algorithm=auto&leaf_size=30').
      to_return(status: 204, body: "", headers: {})

    reducer = described_class.new(key: 'r')
    reducer.reduce_into([], subject_reduction, [])

    expect(a_request(:post, "https://aggregation-caesar.zooniverse.org/reducers/rectangle_reducer?eps=5.0&min_samples=3&metric=euclidean&algorithm=auto&leaf_size=30"))
      .to have_been_made.once
  end
end