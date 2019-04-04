require 'spec_helper'

describe ExtractFetcher do
  let(:wf){ create :workflow }
  let(:s1){ create :subject }
  let(:s2){ create :subject }
  let(:user1_id){ 12345 }
  let(:user2_id){ 23456 }

  describe 'applies filters correctly' do
    it 'by workflow id' do
      wf2 = create :workflow

      e1 = create :extract, subject_id: s1.id, user_id: user1_id, extractor_key: 'e1', workflow: wf
      e2 = create :extract, subject_id: s1.id, user_id: user1_id, extractor_key: 'e2', workflow: wf
      e3 = create :extract, subject_id: s1.id, user_id: user1_id, extractor_key: 'e3', workflow: wf2

      fetcher = ExtractFetcher.new(subject_id: s1.id, workflow_id: wf.id).for(:reduce_by_subject)
      expect(fetcher.extracts).to contain_exactly(e1, e2)
      expect(fetcher.extracts).not_to include(e3)

      fetcher = ExtractFetcher.new(user_id: user1_id, workflow_id: wf.id).for(:reduce_by_user)
      expect(fetcher.extracts).to contain_exactly(e1, e2)
      expect(fetcher.extracts).not_to include(e3)
    end

    it 'by subject' do
      e1 = create :extract, subject_id: s1.id, user_id: user1_id, extractor_key: 'e1', workflow: wf
      e2 = create :extract, subject_id: s1.id, user_id: user1_id, extractor_key: 'e2', workflow: wf
      e3 = create :extract, subject_id: s2.id, user_id: user2_id, extractor_key: 'e1', workflow: wf

      fetcher = ExtractFetcher.new(subject_id: s1.id, workflow_id: wf.id).for(:reduce_by_subject)
      expect(fetcher.extracts).to contain_exactly(e1, e2)
      expect(fetcher.extracts).not_to include(e3)
    end

    it 'by user' do
      e1 = create :extract, subject_id: s1.id, user_id: user1_id, extractor_key: 'e1', workflow: wf
      e2 = create :extract, subject_id: s2.id, user_id: user1_id, extractor_key: 'e1', workflow: wf
      e3 = create :extract, subject_id: s1.id, user_id: user2_id, extractor_key: 'e2', workflow: wf

      fetcher = ExtractFetcher.new(user_id: user1_id, workflow_id: wf.id).for(:reduce_by_user)
      expect(fetcher.extracts).to contain_exactly(e1, e2)
      expect(fetcher.extracts).not_to include(e3)
    end
  end

  describe 'in minimal mode' do
    it 'selects exact subject extracts' do
      e1 = create :extract, subject_id: s1.id, user_id: user1_id, extractor_key: 'e1', workflow: wf
      e2 = create :extract, subject_id: s1.id, user_id: user1_id, extractor_key: 'e2', workflow: wf
      e3 = create :extract, subject_id: s2.id, user_id: user2_id, extractor_key: 'e1', workflow: wf

      fetcher = ExtractFetcher.new(subject_id: s1.id, workflow_id: wf.id)
        .including([e1.id])
        .for(:reduce_by_subject)

      fetcher.strategy! :fetch_minimal

      expect(fetcher.extracts).to contain_exactly(e1)
      expect(fetcher.extracts).not_to include(e2)
      expect(fetcher.extracts).not_to include(e3)
    end

    it 'selects exact user extracts' do
      e1 = create :extract, subject_id: s1.id, user_id: user1_id, extractor_key: 'e1', workflow: wf
      e2 = create :extract, subject_id: s2.id, user_id: user1_id, extractor_key: 'e1', workflow: wf
      e3 = create :extract, subject_id: s1.id, user_id: user2_id, extractor_key: 'e2', workflow: wf

      fetcher = ExtractFetcher.new(user_id: user1_id, workflow_id: wf.id)
        .including([e1.id])
        .for(:reduce_by_user)

      fetcher.strategy! :fetch_minimal

      expect(fetcher.extracts).to contain_exactly(e1)
      expect(fetcher.extracts).not_to include(e2)
      expect(fetcher.extracts).not_to include(e3)
    end

    it 'can find prior reductions' do
      s3 = create :subject

      e1 = create :extract, subject_id: s1.id, user_id: user1_id, extractor_key: 'e1', workflow: wf
      e2 = create :extract, subject_id: s2.id, user_id: user1_id, extractor_key: 'e1', workflow: wf
      e3 = create :extract, subject_id: s3.id, user_id: user1_id, extractor_key: 'e1', workflow: wf

      allow_any_instance_of(Subject)
        .to receive(:additional_subject_ids_for_reduction) do |instance|
          if instance.id==s1.id then [s2.id] else [] end
        end

      fetcher = ExtractFetcher.new(subject_id: s1.id, workflow_id: wf.id)
        .including([e1.id])
        .for(:reduce_by_subject)

      fetcher.strategy! :fetch_minimal

      expect(fetcher.extracts).to contain_exactly(e1,e2)
      expect(fetcher.extracts).not_to include(e3)
    end
  end

  describe 'figures out prior subject ids' do
    it 'when no prior subjects exist' do
      fetch = ExtractFetcher.new @subject_id = s1.id

      expect(fetch.augment_subject_ids([])).to eq([])
      expect(fetch.augment_subject_ids([s1.id])).to eq([s1.id])
      expect(fetch.augment_subject_ids([s1.id, s1.id])).to eq([s1.id])
      expect(fetch.augment_subject_ids([s1.id, s2.id])).to contain_exactly(s1.id, s2.id)
    end

    it 'when a prior subject exists' do
      fetch = ExtractFetcher.new @subject_id = s1.id

      allow_any_instance_of(Subject)
        .to receive(:additional_subject_ids_for_reduction) do |instance|
          if instance.id==s1.id then [s2.id] else [] end
        end

      expect(fetch.augment_subject_ids([s1.id])).to contain_exactly(s1.id, s2.id)
    end
  end
end