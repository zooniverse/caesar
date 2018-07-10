require 'rails_helper'

RSpec.describe Reducer, type: :model do
  let(:extracts) {
    [
      Extract.new(
        :classification_id => 1234,
        :classification_at => Date.new(2014,12,4),
        :data => { "foo" => "bar" }
      ),
      Extract.new(
        :classification_id => 1234,
        :classification_at => Date.new(2014,12,4),
        :data => { "foo" => "baz" }
      ),
      Extract.new(
        :classification_id => 1236,
        :classification_at => Date.new(2017,2,7),
        :data => { "baz" => "bar" }
      ),
      Extract.new(
        :classification_id => 1235,
        :classification_at => Date.new(1980,10,22),
        :data => { "bar" => "baz" }
      ),
      Extract.new(
        :classification_id => 1237,
        :classification_at => Date.new(2017,2,7),
        :data => { "foo" => "fufufu" }
      )
    ]
  }

  subject(:reducer) do
    klass = Class.new(described_class) do
      def reduce_into(extracts, reductions=nil)
        extracts
      end
    end

    klass.new
  end

  it 'filters extracts' do
    extract_filter = instance_double(ExtractFilter, filter: [])
    expect(ExtractFilter).to receive(:new).with({}).and_return(extract_filter)
    subject.filter_extracts(extracts, create(:subject_reduction))
    expect(extract_filter).to have_received(:filter).once
  end

  it 'groups extracts' do
    grouping_filter = instance_double(ExtractGrouping, to_h: {})
    extract_fetcher = instance_double(ExtractFetcher, extracts: extracts)
    reduction_fetcher = instance_double(ReductionFetcher, retrieve: SubjectReduction, has_expired?: false)

    expect(ExtractGrouping).to receive(:new).
      with(extracts, {}).
      and_return(grouping_filter)

    subject.process(extract_fetcher, reduction_fetcher)

    expect(grouping_filter).to have_received(:to_h).once
  end

  it 'does not attempt reduction on repeated failures' do
    reducer= build :reducer

    extract_fetcher = instance_double(ExtractFetcher, extracts: extracts)
    reduction_fetcher = instance_double(ReductionFetcher, retrieve: SubjectReduction, has_expired?: false)

    allow(reducer).to receive(:reduce_into) { raise 'failure' }

    expect { reducer.process(extract_fetcher, reduction_fetcher) }.to raise_error('failure')
    expect { reducer.process(extract_fetcher, reduction_fetcher) }.to raise_error('failure')
    expect { reducer.process(extract_fetcher, reduction_fetcher) }.to raise_error('failure')

    expect(reducer).not_to receive(:reduce_into)
    expect { reducer.process(extract_fetcher, reduction_fetcher) }.to raise_error(Stoplight::Error::RedLight)
  end

  it 'composes grouping and filtering correctly' do
    workflow = build :workflow

    fancy_extracts = [
      build(:extract, extractor_key: 'votes', classification_id: 1, subject_id: 1234, user_id: 5680, data: {"T0" => "ARAI"}),
      build(:extract, extractor_key: 'votes', classification_id: 2, subject_id: 1234, user_id: 5681, data: {"T0" => "ARAI"}),
      build(:extract, extractor_key: 'votes', classification_id: 3, subject_id: 1234, user_id: 5678, data: {"T0" => "ARAI"}),
      build(:extract, extractor_key: 'votes', classification_id: 4, subject_id: 1234, user_id: 5679, data: {"T0" => "ARAI"}),

      build(:extract, extractor_key: 'user_group', classification_id: 1, subject_id: 1234, user_id: 5680, data: {"id"=>"33"}),
      build(:extract, extractor_key: 'user_group', classification_id: 2, subject_id: 1234, user_id: 5681, data: {"id"=>"34"}),
      build(:extract, extractor_key: 'user_group', classification_id: 3, subject_id: 1234, user_id: 5678, data: {"id"=>"33"}),
      build(:extract, extractor_key: 'user_group', classification_id: 4, subject_id: 1234, user_id: 5679, data: {"id"=>"33"}),
    ]

    extract_fetcher = instance_double(ExtractFetcher, extracts: fancy_extracts)
    reduction_fetcher = instance_double(ReductionFetcher, has_expired?: false)

    reducer = build :reducer, key: 'r', grouping: {"field_name" => "user_group.id"}, filters: {"extractor_keys" => ["votes"]}, workflow_id: workflow.id
    allow(reducer).to receive(:get_reduction) do |fetcher, key|
      SubjectReduction.new(
        subject_id: 1234,
        workflow_id: workflow.id,
        reducer_key: 'r'
      ).tap{ |r| r.subgroup = key }
    end
    allow(reducer).to receive(:reduce_into){ |reduce_me, reduce_into_me| create(:subject_reduction, subgroup: reduce_into_me.subgroup, data: reduce_me.map(&:data)) }

    reductions = reducer.process(extract_fetcher, reduction_fetcher)

    expect(reductions[0][:subgroup]).to eq("33")
    expect(reductions[0][:data].count).to eq(3)
    expect(reductions[1][:subgroup]).to eq("34")
    expect(reductions[1][:data].count).to eq(1)
  end

  describe 'validations' do
    it 'is not valid with invalid filters' do
      reducer = Reducer.new filters: {repeated_classifications: "something"}
      expect(reducer).not_to be_valid
      expect(reducer.errors[:extract_filter]).to be_present
    end
  end

  it 'saves reducible attributes' do
    workflow = create :workflow
    reducer = create :stats_reducer, reducible_id: workflow.id, reducible_type: "Workflow"
    expect(reducer.reducible_id).to eq(workflow.id)
    expect(reducer.reducible_type).to eq("Workflow")
  end

  describe 'running/online aggregation' do
    it 'persists associations at the right time' do
      workflow = create :workflow
      subject = create :subject

      extract = create :extract,
        extractor_key: 'foo', subject_id: subject.id, workflow_id: workflow.id

      reduction = create :subject_reduction,
        reducer_key: 'bar', subject_id: subject.id, reducible_id: workflow.id, reducible_type: "Workflow"

      reduction.extracts << extract

      check = SubjectReduction.find(reduction.id)
      expect(check.extract_ids.count).to eq(0)

      reduction.save!

      check = SubjectReduction.find(reduction.id)
      expect(check.extract_ids.count).to eq(1)
    end

    it 'tracks the extracts associated with a reduction' do
      workflow = create :workflow
      subject = create :subject

      extract1 = create :extract,
        extractor_key: 'bbb', subject_id: subject.id, workflow_id: workflow.id

      extract2 = create :extract,
        extractor_key: 'bbb', subject_id: subject.id, workflow_id: workflow.id

      extracts_double = instance_double(ActiveRecord::Relation)

      subject_reduction_double = instance_double(SubjectReduction,
        workflow_id: workflow.id,
        subject_id: subject.id,
        reducer_key: 'aaa',
        extract_ids: [],
        extracts: extracts_double,
        data: "foo"
      )

      running_reducer = create :reducer,
        key: 'aaa',
        type: 'Reducers::PlaceholderReducer',
        topic: Reducer.topics[:reduce_by_subject],
        reduction_mode: Reducer.reduction_modes[:running_reduction],
        reducible_id: workflow.id,
        reducible_type: "Workflow"

      extract_fetcher = instance_double(ExtractFetcher, extracts: [extract1, extract2])
      reduction_fetcher = instance_double(ReductionFetcher, retrieve: [subject_reduction_double], has_expired?: false)

      allow(running_reducer).to receive(:associate_extracts)
      allow(running_reducer).to receive(:reduce_into).and_return(subject_reduction_double)
      allow(running_reducer).to receive(:get_reduction).and_return(subject_reduction_double)
      allow(subject_reduction_double).to receive(:data=)
      allow(subject_reduction_double).to receive(:expired=)

      running_reducer.process(extract_fetcher, reduction_fetcher)
      expect(running_reducer).to have_received(:associate_extracts).with(subject_reduction_double, [extract1, extract2])
    end

    it 'includes a given extract in a running reduction only once' do
      workflow = create :workflow
      subject = create :subject

      extract1 = create :extract,
        extractor_key: 'bbb', subject_id: subject.id, workflow_id: workflow.id

      extract2 = create :extract,
        extractor_key: 'bbb', subject_id: subject.id, workflow_id: workflow.id

      extracts_double = instance_double(ActiveRecord::Relation)

      subject_reduction_double = instance_double(SubjectReduction,
        workflow_id: workflow.id,
        subject_id: subject.id,
        reducer_key: 'aaa',
        extract_ids: [extract1.id],
        extracts: extracts_double,
        data: "foo"
      )

      extract_fetcher = instance_double(ExtractFetcher, extracts: [extract1, extract2])
      reduction_fetcher = instance_double(ReductionFetcher, retrieve: [subject_reduction_double], has_expired?: false)

      running_reducer = create :reducer,
        key: 'aaa',
        type: 'Reducers::PlaceholderReducer',
        topic: Reducer.topics[:reduce_by_subject],
        reduction_mode: Reducer.reduction_modes[:running_reduction],
        reducible_id: workflow.id,
        reducible_type: "Workflow"

      allow(running_reducer).to receive(:get_reduction).and_return(subject_reduction_double)
      allow(running_reducer).to receive(:reduce_into).and_return(subject_reduction_double)
      allow(running_reducer).to receive(:associate_extracts)
      allow(subject_reduction_double).to receive(:data=)
      allow(subject_reduction_double).to receive(:expired=)

      running_reducer.process(extract_fetcher, reduction_fetcher)
      expect(running_reducer).to have_received(:reduce_into).with([extract2], subject_reduction_double)
    end
  end
end
