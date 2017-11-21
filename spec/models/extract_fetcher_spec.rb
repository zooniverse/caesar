require 'spec_helper'

describe ExtractFetcher, :type => :model do
  describe '#user_extracts' do
    it 'gets user extracts' do
      workflow = create(:workflow)

      create :extract, extractor_key: 's', workflow_id: workflow.id, user_id: 1234, classification_id: 11111, data: { LN: 1 }
      create :extract, extractor_key: 's', workflow_id: workflow.id, user_id: 1234, classification_id: 22222, data: { LN: 1 }
      create :extract, extractor_key: 's', workflow_id: workflow.id, user_id: 1235, classification_id: 33333, data: { LN: 1 }

      fetcher = described_class.new(workflow.id, nil, 1234)

      expect(fetcher.user_extracts.count).to eq(2)
    end
  end

  describe '#subject_extracts' do
    it 'gets subject extracts' do
      workflow = create(:workflow)
      subject = create(:subject)
      other_subject = create(:subject)

      create :extract, extractor_key: 's', workflow_id: workflow.id, subject_id: subject.id, classification_id: 11111, data: { LN: 1 }
      create :extract, extractor_key: 's', workflow_id: workflow.id, subject_id: subject.id, classification_id: 22222, data: { LN: 1 }
      create :extract, extractor_key: 's', workflow_id: workflow.id, subject_id: other_subject.id, classification_id: 33333, data: { LN: 1 }

      fetcher = described_class.new(workflow.id, subject.id, nil)

      expect(fetcher.subject_extracts.count).to eq(2)
    end
  end

end
