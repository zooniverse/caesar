require 'spec_helper'

describe Reducer, type: :model, focus: true do
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

  let(:reducer) do
    klass = Class.new(described_class) do
      def reduce_into(extracts, reductions=nil)
        extracts
      end
    end

    klass.new
  end

  it 'does not try to reduce empty extract sets' do
    s1 = create :subject
    allow_any_instance_of(ExtractFetcher).to receive(:extracts).and_return([])

    expect(reducer).not_to receive(:reduce_into)
    reducer.process([], [], subject_id: s1.id)
  end

  it 'expects a reduction decorator instance to be passed to the custom reduce_into' do
    expect(reducer).to receive(:reduce_into).with(instance_of(Array), instance_of(Reducer::ReductionState))
    reducer.process(extracts, [], subject_id: 1)
  end

  it 'filters extracts' do
    extract_filter = instance_double(ExtractFilter)
    expect(ExtractFilter).to receive(:new).and_return(extract_filter)
    expect(extract_filter).to receive(:apply).once.and_return([])

    reducer.filter_extracts(extracts, create(:subject_reduction))
  end

  it 'groups extracts' do
    grouping_filter = instance_double(ExtractGrouping, to_h: {})

    expect(ExtractGrouping).to receive(:new).
      with(extracts, {}).
      and_return(grouping_filter)

    reducer.process(extracts, SubjectReduction.new)

    expect(grouping_filter).to have_received(:to_h).once
  end

  it 'does not attempt reduction on repeated failures' do
    reducer= build :reducer
    allow(reducer).to receive(:reduce_into) { raise 'failure' }

    expect { reducer.process(extracts, [SubjectReduction.new]) }.to raise_error('failure')
    expect { reducer.process(extracts, [SubjectReduction.new]) }.to raise_error('failure')
    expect { reducer.process(extracts, [SubjectReduction.new]) }.to raise_error('failure')

    expect(reducer).not_to receive(:reduce_into)
    expect do
      reducer.process(extracts, [SubjectReduction.new])
    end.to raise_error(Stoplight::Error::RedLight)
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
    allow(extract_fetcher).to receive(:strategy!)

    reducer = build :reducer, key: 'r', grouping: {"field_name" => "user_group.id"}, filters: {"extractor_keys" => ["votes"]}, workflow_id: workflow.id

    allow(reducer).to receive(:get_group_reduction) do |fetcher, key|
      SubjectReduction.new(
        subject_id: 1234,
        workflow_id: workflow.id,
        reducer_key: 'r'
      ).tap{ |r| r.subgroup = key }
    end

    allow(reducer).to receive(:reduce_into) do |reduce_me, reduce_into_me|
      build :subject_reduction, subgroup: reduce_into_me.subgroup, data: reduce_me.map(&:data)
    end

    reductions = reducer.process(fancy_extracts, [])

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

      allow(running_reducer).to receive(:associate_extracts)
      allow(running_reducer).to receive(:reduce_into).and_return(subject_reduction_double)
      allow(running_reducer).to receive(:get_group_reduction).and_return(subject_reduction_double)
      allow(subject_reduction_double).to receive(:data=)

      running_reducer.process([extract1, extract2], [subject_reduction_double])
      expect(running_reducer).to have_received(:associate_extracts).with(subject_reduction_double, [extract1, extract2])
    end

    it 'includes a given extract in a running reduction only once' do
      workflow = create :workflow
      subject = create :subject

      extract1 = create :extract,
        extractor_key: 'bbb', subject_id: subject.id, workflow_id: workflow.id

      extract2 = create :extract,
        extractor_key: 'bbb', subject_id: subject.id, workflow_id: workflow.id

      subject_reduction = create(
        :subject_reduction,
        reducible: workflow,
        subject: subject,
        reducer_key: 'bbb',
        extracts: [extract1],
        data: 'foo'
      )

      running_reducer = create(
        :placeholder_reducer,
        key: 'aaa',
        type: 'Reducers::PlaceholderReducer',
        topic: Reducer.topics[:reduce_by_subject],
        reduction_mode: Reducer.reduction_modes[:running_reduction],
        reducible_id: workflow.id,
        reducible_type: 'Workflow'
      )

      reduction_state_double = Reducer::ReductionState.new(
        subject_reduction,
        running_reducer.running_reduction?
      )
      allow(Reducer::ReductionState).to receive(:new).and_return(reduction_state_double)

      expect(running_reducer).to receive(:reduce_into).with(
        [extract2],
        reduction_state_double
      ).and_call_original
      running_reducer.process([extract1, extract2], [subject_reduction])
    end
  end

  describe "relevant reductions" do
    let(:workflow) { create(:workflow) }

    it 'include user reductions' do
      subject_reducer = create(:stats_reducer,
                                reducible: workflow,
                                topic: Reducer.topics[:reduce_by_subject],
                                config: {user_reducer_keys: "skillz"}
                              )
      new_extracts = [
        build(:extract, classification_id: 1, subject_id: 1234, user_id: 1, data: {x: 1, y: 2}),
        build(:extract, classification_id: 2, subject_id: 1234, user_id: 2, data: {x: 2, y: 2}),
        build(:extract, classification_id: 3, subject_id: 1234, user_id: 3, data: {x: 3, y: 1})
      ]

      reductions = [
        create(:user_reduction, data: {skill: 15}, user_id: 1, reducible: workflow, reducer_key: 'skillz'),
        create(:user_reduction, data: {skill: 22}, user_id: 2, reducible: workflow, reducer_key: 'skillz')
      ]

      augmented_extracts = subject_reducer.augment_extracts(new_extracts)

      expect(augmented_extracts[0]).to have_attributes(relevant_reduction: reductions[0])
      expect(augmented_extracts[1]).to have_attributes(relevant_reduction: reductions[1])
      expect(augmented_extracts[2]).to have_attributes(relevant_reduction: nil)
    end

    it 'include subject reductions' do
      subjects = create_list(:subject, 2)
      user_reducer = create(:stats_reducer,
                             reducible: workflow,
                             topic: Reducer.topics[:reduce_by_user],
                             reduction_mode: Reducer.reduction_modes[:running_reduction],
                             config: {subject_reducer_keys: "difficulty"}
                           )

      new_extracts = [
        build(:extract, workflow_id: workflow.id, subject_id: subjects[0].id, user_id: 1, data: { feedback: {} } ),
        build(:extract, workflow_id: workflow.id, subject_id: subjects[1].id, user_id: 1, data: { feedback: {} } ),
        build(:extract, workflow_id: workflow.id, subject_id: 999, user_id: 1, data: { feedback: {} } ),
      ]

      reductions = [
        create(:subject_reduction, data: {difficulty: [0.7, 0.3, 0.1] }, subject_id: subjects[0].id, reducible: workflow, reducer_key: 'difficulty'),
        create(:subject_reduction, data: {difficulty: [0.4, 0.2, 0.8] }, subject_id: subjects[1].id, reducible: workflow, reducer_key: 'difficulty')
      ]

      augmented_extracts = user_reducer.augment_extracts(new_extracts)

      expect(augmented_extracts[0]).to have_attributes(relevant_reduction: reductions[0])
      expect(augmented_extracts[1]).to have_attributes(relevant_reduction: reductions[1])
      expect(augmented_extracts[2]).to have_attributes(relevant_reduction: nil)
    end
  end

  describe '#get_group_reduction' do
    it 'returns an existing reduction' do
      wf = create :workflow
      reducer = create :reducer, reducible: wf, type: 'Reducers::PlaceholderReducer'

      sr1 = build :subject_reduction, subgroup: 'bar', reducible: wf, data: 'bar'
      sr2 = build :subject_reduction, subgroup: 'foo', reducible: wf, data: 'foo'

      expect(reducer.get_group_reduction([sr1, sr2], 'foo')).to be(sr2)
    end

    it 'creates a subject reduction when needed' do
      subject = create :subject
      wf = create :workflow

      reducer = create :reducer,
        reducible: wf,
        type: 'Reducers::PlaceholderReducer',
        key: 'r',
        topic: :reduce_by_subject

      reducer.instance_variable_set(:@subject_id, subject.id)

      sr1 = build :subject_reduction,
        subgroup: 'bar',
        reducible: wf,
        data: 'bar',
        subject_id: subject.id,
        reducer_key: 'r'

      result = reducer.get_group_reduction([sr1], 'foo')
      expect(result).not_to be_nil
      expect(result).to be_a(SubjectReduction)
      expect(result.subgroup).to eq('foo')
      expect(result.subject_id).to eq(subject.id)
    end

    it 'creates a user reduction when needed' do
      wf = create :workflow

      reducer = create :reducer,
        reducible: wf,
        type: 'Reducers::PlaceholderReducer',
        key: 'r',
        topic: :reduce_by_user

      reducer.instance_variable_set(:@user_id, 1234)

      ur1 = build :user_reduction,
        subgroup: 'bar',
        reducible: wf,
        data: 'bar',
        user_id: 1234,
        reducer_key: 'r'

      result = reducer.get_group_reduction([ur1], 'foo')
      expect(result).not_to be_nil
      expect(result).to be_a(UserReduction)
      expect(result.subgroup).to eq('foo')
      expect(result.user_id).to eq(1234)
    end
  end

  describe '#filter_extracts' do
    it 'does not reduce the same extract twice' do
      ex1 = create :extract
      sr1 = build :subject_reduction
      reducer = build :reducer, reduction_mode: :running_reduction

      expect(sr1).to receive(:extract_ids).and_return([ex1.id])
      expect(reducer.filter_extracts([ex1], sr1)).to be_empty
    end

    it 'applies the configured filters' do
      ex1 = create :extract
      reducer = build :reducer

      ef_double = instance_double(ExtractFilter, apply: [ex1])
      expect(reducer).to receive(:extract_filter).and_return(ef_double)
      expect(ef_double).to receive(:apply).with([ex1]).and_return([ex1])
      reducer.filter_extracts([ex1], SubjectReduction.new)
    end
  end

  describe '#get_relevant_reductions' do
    it 'does nothing unless relevant reductions are configured' do
      reducer = build :reducer

      ex1 = build :extract
      ex2 = build :extract

      expect(reducer).to receive(:user_reducer_keys).once
      expect(reducer).to receive(:subject_reducer_keys).once
      expect(reducer).not_to receive(:reduce_by_subject?)
      expect(reducer).not_to receive(:reduce_by_user?)

      reducer.get_relevant_reductions([ex1, ex2])
    end

    it 'finds relevant user reductions' do
      wf = create :workflow
      reducer = build :reducer, topic: :reduce_by_subject, reducible: wf, user_reducer_keys: 'foo'
      ex = build :extract, user_id: 1234
      ur = build :user_reduction, user_id: 1234, reducer_key: 'foo'

      reductions_double = instance_double(ActiveRecord::Relation)
      allow(reductions_double).to receive(:to_a).and_return([ur])

      expect(UserReduction).to receive(:where).with(
        user_id: [1234],
        reducible: wf,
        reducer_key: 'foo'
      ).and_return(reductions_double)

      result = reducer.get_relevant_reductions([ex])
      expect(result.to_a).to include(ur)
    end

    it 'finds relevant subject reductions' do
      wf = create :workflow
      subject = create :subject
      reducer = build :reducer, topic: :reduce_by_user, reducible: wf, subject_reducer_keys: 'foo'
      ex = build :extract, subject_id: subject.id
      ur = build :subject_reduction, subject_id: subject.id, reducer_key: 'foo'

      reductions_double = instance_double(ActiveRecord::Relation)
      allow(reductions_double).to receive(:to_a).and_return([ur])

      expect(SubjectReduction).to receive(:where).with(
        subject_id: [subject.id],
        reducible: wf,
        reducer_key: 'foo'
      ).and_return(reductions_double)

      result = reducer.get_relevant_reductions([ex])
      expect(result.to_a).to include(ur)
    end
  end
end
