require 'spec_helper'

describe ExtractGrouping do
  after do
    Extract.delete_all
  end

  let(:extracts){
    [
      Extract.new(extractor_id: 's', workflow_id: 1234, subject_id: 2345, classification_id: 11111, classification_at: DateTime.now, data: { LN: 1 }),
      Extract.new(extractor_id: 's', workflow_id: 1234, subject_id: 2345, classification_id: 22222, classification_at: DateTime.now, data: { LN: 1 }),
      Extract.new(extractor_id: 's', workflow_id: 1234, subject_id: 2345, classification_id: 33333, classification_at: DateTime.now, data: { TGR: 1 }),
      Extract.new(extractor_id: 'g', workflow_id: 1234, subject_id: 2345, classification_id: 11111, classification_at: DateTime.now, data: { classroom: 1 }),
      Extract.new(extractor_id: 'g', workflow_id: 1234, subject_id: 2345, classification_id: 22222, classification_at: DateTime.now, data: { classroom: 1 }),
      Extract.new(extractor_id: 'g', workflow_id: 1234, subject_id: 2345, classification_id: 33333, classification_at: DateTime.now, data: { classroom: 1 }),

      Extract.new(extractor_id: 's', workflow_id: 1234, subject_id: 2345, classification_id: 44444, classification_at: DateTime.now, data: { LN: 1 }),
      Extract.new(extractor_id: 's', workflow_id: 1234, subject_id: 2345, classification_id: 55555, classification_at: DateTime.now, data: { LN: 1, BR: 1 }),
      Extract.new(extractor_id: 'g', workflow_id: 1234, subject_id: 2345, classification_id: 44444, classification_at: DateTime.now, data: { classroom: 2 }),
      Extract.new(extractor_id: 'g', workflow_id: 1234, subject_id: 2345, classification_id: 55555, classification_at: DateTime.now, data: { classroom: 2 })
    ]
  }

  let(:nogroup){
    ExtractGrouping.new(extracts, nil)
  }

  let(:grouping){
    ExtractGrouping.new(extracts, "g.classroom")
  }

  describe '#to_h' do
    it('works when no grouping is defined') do
      grouped = nogroup.to_h
      expect(grouped).to have_key("_default")
      expect(grouped["_default"]).to eq(extracts)
    end

    it('throws an error if an extract is missing the key') do
      expect { ExtractGrouping.new(extracts,"h.classroom").to_h }.to raise_error(MissingGroupingField)
      expect { ExtractGrouping.new(extracts,"g.foo").to_h }.to raise_error(MissingGroupingField)
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

end
