require 'spec_helper'

describe FetchExtractsByUser do
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

      extracts = described_class.new.extracts({user_id: user1_id, workflow_id: wf.id}, [])
      expect(extracts).to contain_exactly(e1, e2)
      expect(extracts).not_to include(e3)
    end

    it 'by user' do
      e1 = create :extract, subject_id: s1.id, user_id: user1_id, extractor_key: 'e1', workflow: wf
      e2 = create :extract, subject_id: s2.id, user_id: user1_id, extractor_key: 'e1', workflow: wf
      e3 = create :extract, subject_id: s1.id, user_id: user2_id, extractor_key: 'e2', workflow: wf

      extracts = described_class.new.extracts({user_id: user1_id, workflow_id: wf.id}, [])
      expect(extracts).to contain_exactly(e1, e2)
      expect(extracts).not_to include(e3)
    end
  end

  describe 'in minimal mode' do
    it 'selects exact user extracts' do
      e1 = create :extract, subject_id: s1.id, user_id: user1_id, extractor_key: 'e1', workflow: wf
      e2 = create :extract, subject_id: s2.id, user_id: user1_id, extractor_key: 'e1', workflow: wf
      e3 = create :extract, subject_id: s1.id, user_id: user2_id, extractor_key: 'e2', workflow: wf

      extracts = described_class.new(:fetch_minimal).extracts({user_id: user1_id, workflow_id: wf.id}, [e1.id])

      expect(extracts).to contain_exactly(e1)
      expect(extracts).not_to include(e2)
      expect(extracts).not_to include(e3)
    end
  end

  it 'skips getting user extracts if user id is nil' do
    create :extract, workflow: wf, user_id: user1_id
    nil_extract = create :extract, workflow: wf, user_id: nil

    allow(Extract).to receive(:where).and_return([nil_extract])

    extracts = described_class.new.extracts({user_id: nil}, [])

    expect(Extract).not_to have_received(:where)
    expect(extracts).to be_empty
  end
end
