require 'spec_helper'

describe Extractor do
  let(:workflow){ create :workflow }
  let(:subject){ create :subject }
  let(:classification) do
    Classification.new(
      "id"=>"12281870",
      "created_at"=>"2016-05-16T09:34:23.682Z",
      "updated_at"=>"2016-05-16T09:34:23.750Z",
      "workflow_version"=>"332.94",
      "annotations"=>[
        {
          "task"=>"T1",
          "value"=>[
            {"choice"=>"LK", "answers"=>{"BHVR"=>["RSTNG"], "DLTS"=>"1", "CLLRPRSNT"=>"S"}, "filters"=>{}}
          ]
        }
      ],
      "metadata"=>{
        "session"=>"8911f478cc88fba60af9e9960531aea7bf5c724cc17970dd64ee129f1881f5e6",
        "viewport"=>{"width"=>1360, "height"=>653},
        "started_at"=>"2016-05-16T09:33:40.181Z",
        "user_agent"=>"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36",
        "utc_offset"=>"-10800",
        "finished_at"=>"2016-05-16T09:34:23.243Z",
        "live_project"=>true,
        "user_language"=>"en",
        "user_group_ids"=>[],
        "subject_dimensions"=>[
          {"clientWidth"=>732, "clientHeight"=>549, "naturalWidth"=>800, "naturalHeight"=>600},
          {"clientWidth"=>732, "clientHeight"=>549, "naturalWidth"=>800, "naturalHeight"=>600},
          {"clientWidth"=>732, "clientHeight"=>549, "naturalWidth"=>800, "naturalHeight"=>600}
        ],
        "workflow_version"=>"332.94"
      },
      "links"=>{
        "project"=>"2439",
        "user"=>"1",
        "workflow"=>workflow.id.to_s,
        "workflow_content"=>"1716",
        "subjects"=>[subject.id.to_s]
      }
    )
  end

  describe 'minimum_workflow_version' do
    it 'disallows letters for min_workflow_version' do
      extractor = build :extractor, minimum_workflow_version: 'any', workflow: workflow
      expect(extractor).to_not be_valid
    end

    it 'allows string of numbers for min_workflow_version' do
      extractor = build :extractor, minimum_workflow_version: '1.8', workflow: workflow
      expect(extractor).to be_valid
    end

    it 'allows numerics for min_workflow_version' do
      extractor = build :extractor, minimum_workflow_version: 3.14, workflow: workflow
      expect(extractor).to be_valid
    end

    it 'allows nil for min_workflow_version' do
      extractor = build :extractor, workflow: workflow
      expect(extractor).to be_valid
    end
  end

  describe '#process' do
    it 'processes normally when nothing is changed' do
      extractor = build :extractor, key: 'r'
      allow(extractor).to receive(:extract_data_for).and_return(nil)
      extractor.process(classification)

      expect(extractor).to have_received(:extract_data_for)
    end

    it 'processes classifications normally if they are new enough' do
      extractor = build :extractor, key: 'r', minimum_workflow_version: '3'
      allow(extractor).to receive(:extract_data_for).and_return(nil)
      extractor.process(classification)

      expect(extractor).to have_received(:extract_data_for)
    end

    it 'processes classifications normally if workflow version is unknown' do
      allow(classification).to receive(:workflow_version).and_return(nil)
      extractor = build :extractor, key: 'r', minimum_workflow_version: '3'
      allow(extractor).to receive(:extract_data_for).and_return(nil)
      extractor.process(classification)

      expect(extractor).to have_received(:extract_data_for)
    end

    it 'returns no data when a classification is too old' do
      extractor = build :extractor, key: 'r',minimum_workflow_version: '335.4.6'
      allow(extractor).to receive(:extract_data_for).and_return(nil)
      extract = extractor.process(classification)

      expect(extractor).not_to have_received(:extract_data_for)
      expect(extract).to be(Extractor::NoData)
    end

    it 'does not attempt extraction on repeated failures' do
      extractor = build :extractor
      allow(extractor).to receive(:extract_data_for) { raise 'failure' }

      expect { extractor.process(classification) }.to raise_error('failure')
      expect { extractor.process(classification) }.to raise_error('failure')
      expect { extractor.process(classification) }.to raise_error('failure')

      expect(extractor).not_to receive(:extract_data_for)
      expect { extractor.process(classification) }.to raise_error(Stoplight::Error::RedLight)
    end
  end
end
