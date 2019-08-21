describe RunsExtractors do
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

  let(:workflow) do
    create(:workflow, project_id: 1,
                      extractors: [build(:survey_extractor, key: 's', config: {"task_key" => "T1"})]) do |w|
      create :reducer, reducible: w, key: 'r', type: 'Reducers::PlaceholderReducer'
    end
  end

  let(:subject) { Subject.create }

  let(:runner) do
    Workflow.find(workflow.id).extractors_runner
  end

  let(:panoptes) {
    instance_double(
      Panoptes::Client,
      retire_subject: true,
      workflow: {},
      project: {},
      get_subject_classifications: {"classifications" => []},
      get_user_classifications: {"classifications" => []}
    )
  }

  before do
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  describe 'extraction' do
    it 'updates attributes if not set yet' do
      extract = create :extract,
                       workflow_id: classification.workflow_id,
                       subject_id: classification.subject_id,
                       classification_id: classification.id,
                       extractor_key: 's',
                       project_id: nil,
                       user_id: nil
      runner.extract(classification)
      expect(extract.reload.project_id).to eq(2439)
      expect(extract.reload.user_id).to eq(1)
    end
  end

  describe '#extract' do
    let(:blank_extractor){ instance_double(Extractors::BlankExtractor, key: 'blank', config: {task_key: 'T1'}, process: nil) }
    let(:question_extractor){ instance_double(Extractors::QuestionExtractor, key: 'question', config: {task_key: 'T1'}, process: nil) }
    let(:extractors){ [blank_extractor, question_extractor] }
    let(:runner) { RunsExtractors.new(extractors) }

    it 'calls all defined extractors' do
      expect(blank_extractor).to receive(:process).once
      expect(question_extractor).to receive(:process).once

      runner.extract(classification)
    end

    it 'does not save the extract if there is no data' do
      plucker = instance_double(Extractors::PluckFieldExtractor, key: 'pluck', config: {if_missing: 'reject'}, process: nil)
      allow(plucker).to receive(:process).and_return(Extractor::NoData)
      expect do
        RunsExtractors.new([plucker]).extract(classification)
      end.to_not change{Extract.count}
    end

    describe 'error handling' do
      class DummyException < StandardError; end

      it 'raises an overall error if one of the extractors doesnt work' do
        allow(blank_extractor).to receive(:process).and_raise(DummyException.new('boo'))
        allow(question_extractor).to receive(:process)

        expect do
          runner.extract(classification)
        end.to raise_error(Extractor::ExtractionFailed)
      end

      it 'calls all defined extractors even when one fails' do
        allow(blank_extractor).to receive(:process).and_raise(DummyException.new('boo'))
        expect(blank_extractor).to receive(:process).once
        expect(question_extractor).to receive(:process).once

        begin
          runner.extract(classification)
        rescue
        end
      end

      it 'logs all exceptions to rollbar' do
        allow(blank_extractor).to receive(:process).and_raise(DummyException.new('boo'))
        expect(question_extractor).to receive(:process).and_raise(StandardError.new('boo'))

        expect(Rollbar).to receive(:error).with(instance_of(DummyException), use_exception_level_filters: true)
        expect(Rollbar).to receive(:error).with(instance_of(StandardError), use_exception_level_filters: true)
        begin
          runner.extract(classification)
        rescue
        end
      end

      it 'queues the reduction if we ask it to' do
        expect(ReduceWorker).to receive(:perform_async).once
        runner.extract(classification, and_reduce: true)
      end

      it 'queues the reduction correctly if there is an external reducer' do
        create :external_reducer, reducible: workflow
        expect(ReduceWorkerExternal).to receive(:perform_async).once
        runner.extract(classification, and_reduce: true)
      end
    end
  end
end
