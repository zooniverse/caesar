require 'spec_helper'

describe ReductionFetcher do
  it 'is constructed correctly' do
    f = described_class.new user_id: 1234
    expect(f.query).to eq(user_id: 1234)
    expect(f.loaded).to be_falsy
  end

  describe 'prefetching' do
    let(:fetcher){ described_class.new({}) }
    it 'prefetches if you tell it to' do
      sr = instance_double(ActiveRecord::Relation, load: nil)
      ur = instance_double(ActiveRecord::Relation, load: nil)
      expect(fetcher).to receive(:subject_reductions).and_return(sr)
      expect(fetcher).to receive(:user_reductions).and_return(ur)
      expect(sr).to receive(:load)
      expect(ur).to receive(:load)

      res = fetcher.load!
      expect(fetcher.loaded).to be_truthy
      expect(res).to eq(fetcher)
    end

    it 'only prefetches once' do
      sr = instance_double(ActiveRecord::Relation, load: nil)
      ur = instance_double(ActiveRecord::Relation, load: nil)
      expect(fetcher).to receive(:subject_reductions).and_return(sr)
      expect(fetcher).to receive(:user_reductions).and_return(ur)
      expect(sr).to receive(:load).once
      expect(ur).to receive(:load).once

      fetcher.load!
      fetcher.load!
    end
  end

  describe '#search' do
    let(:subject){ create :subject }

    context 'when loading normally' do
      let(:fetcher){ described_class.new(user_id: 1234, subject_id: subject.id) }

      it 'loads user reductions correctly' do
        fetcher.for! :reduce_by_user

        ur = instance_double(ActiveRecord::Relation, load: nil)
        expect(fetcher).to receive(:user_reductions).and_return(ur)
        expect(ur).to receive(:where).with(
          user_id: 1234,
          foo: 'bar'
        ).and_return(UserReduction.none)

        res = fetcher.search(foo: 'bar')
        expect(res).to eq([])
      end

      it 'loads subject reductions correctly' do
        fetcher.for! :reduce_by_subject

        sr = instance_double(ActiveRecord::Relation, load: nil)
        expect(fetcher).to receive(:subject_reductions).and_return(sr)
        expect(sr).to receive(:where).with(
          subject_id: subject.id,
          foo: 'bar'
        ).and_return(SubjectReduction.none)

        res = fetcher.search(foo: 'bar')
        expect(res).to eq([])
      end
    end

    context 'when pre-fetched' do
      let(:fetcher){ described_class.new(user_id: 1234, subject_id: subject.id).load! }

      it 'loads user reductions correctly' do
        fetcher.for! :reduce_by_user

        expect(fetcher).to receive(:locate_in_place).with(
          user_id: 1234,
          foo: 'bar'
        ).and_return(UserReduction.none)

        res = fetcher.search(foo: 'bar')
        expect(res).to eq([])
      end

      it 'loads subject reductions correctly' do
        fetcher.for! :reduce_by_subject

        expect(fetcher).to receive(:locate_in_place).with(
          subject_id: subject.id,
          foo: 'bar'
        ).and_return(SubjectReduction.none)

        res = fetcher.search(foo: 'bar')
        expect(res).to eq([])
      end
    end
  end

  describe '#source_relation' do
    it 'returns the right relation' do
      fetcher = described_class.new({})

      fetcher.for! :reduce_by_subject
      expect(fetcher.source_relation.klass).to be(SubjectReduction)

      fetcher.for! :reduce_by_user
      expect(fetcher.source_relation.klass).to be(UserReduction)
    end
  end

  describe '#locate_in_place' do
    let(:subject1){ create :subject }
    let(:subject2){ create :subject }
    it 'returns matching records' do
      fetcher = described_class.new({})
      sr1 = build(:subject_reduction, subject_id: subject1.id)
      sr2 = build(:subject_reduction, subject_id: subject2.id)

      allow(fetcher).to receive(:source_relation).and_return([sr1, sr2])

      expect(sr1).to receive(:[]).with(:subject_id).and_return(subject1.id)
      expect(sr2).to receive(:[]).with(:subject_id).and_return(subject2.id)

      res = fetcher.locate_in_place(subject_id: subject2.id)

      expect(res.size).to eq(1)
      expect(res[0]).to be(sr2)
    end
  end

  describe '#key_match' do
    let(:workflow){ create :workflow }
    let(:subject1){ create :subject }
    let(:subject2){ create :subject }

    it 'requires all keys to match' do
      fetcher = described_class.new({})
      sr1 = create :subject_reduction, subject_id: subject1.id, reducible: workflow
      sr2 = create :subject_reduction, subject_id: subject2.id, reducible: workflow

      keys = { subject_id: subject1.id, reducible_id: workflow.id }

      expect(fetcher.key_match(sr1, keys)).to be_truthy
      expect(fetcher.key_match(sr2, keys)).to be_falsy
    end
  end
end
