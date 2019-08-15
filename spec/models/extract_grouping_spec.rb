require 'spec_helper'

describe ExtractGrouping do
  let(:workflow){ create :workflow }
  let(:subject){ create :subject }
  let(:extracts){
    [
      # "classroom 1" extracts
      create(:extract, extractor_key: 's', workflow_id: workflow.id, subject_id: subject.id, classification_id: 11111, data: { LN: 1 }),
      create(:extract, extractor_key: 's', workflow_id: workflow.id, subject_id: subject.id, classification_id: 22222, data: { LN: 1 }),
      create(:extract, extractor_key: 's', workflow_id: workflow.id, subject_id: subject.id, classification_id: 33333, data: { TGR: 1 }),

      create(:extract, extractor_key: 'g', workflow_id: workflow.id, subject_id: subject.id, classification_id: 11111, data: { classroom: 1 }),
      create(:extract, extractor_key: 'g', workflow_id: workflow.id, subject_id: subject.id, classification_id: 22222, data: { classroom: 1 }),
      create(:extract, extractor_key: 'g', workflow_id: workflow.id, subject_id: subject.id, classification_id: 33333, data: { classroom: 1 }),

      # "classroom 2" extracts
      create(:extract, extractor_key: 's', workflow_id: workflow.id, subject_id: subject.id, classification_id: 44444, data: { LN: 1 }),
      create(:extract, extractor_key: 's', workflow_id: workflow.id, subject_id: subject.id, classification_id: 55555, data: { LN: 1, BR: 1 }),

      create(:extract, extractor_key: 'g', workflow_id: workflow.id, subject_id: subject.id, classification_id: 44444, data: { classroom: 2 }),
      create(:extract, extractor_key: 'g', workflow_id: workflow.id, subject_id: subject.id, classification_id: 55555, data: { classroom: 2 })
    ]
  }

  let(:nogroup){
    ExtractGrouping.new(extracts, {})
  }

  let(:grouping){
    ExtractGrouping.new(extracts, {"field_name" => "g.classroom"})
  }

  describe '#to_h' do
    it('works when no grouping is defined') do
      grouped = nogroup.to_h
      expect(grouped).to have_key("_default")
      expect(grouped["_default"]).to eq(extracts)
    end

    it('throws an error if an extract is missing the key') do
      expect { ExtractGrouping.new(extracts,{"field_name" => "h.classroom", "if_missing" => "error"}).to_h }.to raise_error(MissingGroupingField)
      expect { ExtractGrouping.new(extracts,{"field_name" => "h.classroom", "if_missing" => "ignore"}).to_h }.not_to raise_error
      expect { ExtractGrouping.new(extracts,{"field_name" => "g.foo", "if_missing" => "error"}).to_h }.to raise_error(MissingGroupingField)
    end

    it('groups extracts correctly') do
      grouped = grouping.to_h
      expect(grouped.keys.sort()).to eq([1, 2])

      expect(grouped[1]).to include(extracts[0])
      expect(grouped[1]).not_to include(extracts[6])

      expect(grouped[2]).not_to include(extracts[0])
      expect(grouped[2]).to include(extracts[6])
    end
  end

  it 'throws away nil subgroups' do
    extracts

    # having a nil value in the grouping field should be treated as an error
    create(:extract, extractor_key: 's', workflow_id: workflow.id, subject_id: subject.id, classification_id: 66666, data: { LN: 1 })
    create(:extract, extractor_key: 'g', workflow_id: workflow.id, subject_id: subject.id, classification_id: 66666, data: { classroom: nil })

    expect do
      ExtractGrouping.new(Extract.all, { 'field_name' => 'g.classroom', 'if_missing' => 'error' }).to_h
    end.to raise_error(MissingGroupingField)
  end

  it 'tolerates classifications with missing grouping fields' do
    create :extract, extractor_key: 's', workflow: workflow, subject_id: subject.id, classification_id: 1234, data: { LN: 1 }
    create :extract, extractor_key: 'g', workflow: workflow, subject_id: subject.id, classification_id: 1234, data: { classroom: 'aa' }

    create :extract, extractor_key: 's', workflow: workflow, subject_id: subject.id, classification_id: 2345, data: { LN: 1 }
    # do not create this extract; this way, the extracts for this classification will be ignored
    # create :extract, extractor_key: 'g', workflow: workflow, subject_id: subject.id, classification_id: 2345, data: { classroom: 'aa' }

    create :extract, extractor_key: 's', workflow: workflow, subject_id: subject.id, classification_id: 3456, data: { LN: 1 }
    create :extract, extractor_key: 'g', workflow: workflow, subject_id: subject.id, classification_id: 3456, data: { classroom: 'aa' }

    grouper = described_class.new(Extract.all, { 'field_name' => 'g.classroom', 'if_missing' => 'ignore'})
    groups = grouper.to_h

    expect(groups.keys).to eq(['aa'])
    expect(groups['aa'].count).to eq(4)
  end
end
