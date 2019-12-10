describe RunsUserReducers do
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
        create :subject_rule, workflow: w, subject_rule_effects: [build(:subject_rule_effect, config: {reason: "consensus"})]
      end
    end
  
    let(:reducers) do
      [
        create(:stats_reducer, key: 's', reducible: workflow),
        create(:stats_reducer, key: 'g', grouping: {"field_name" => "s.LK"}, reducible: workflow)
      ]
    end
  
    let(:subject) { Subject.create }
  
    let(:runner) do
      RunsUserReducers.new(workflow, reducers)
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
  
    it 'reduces by user instead of subject if we tell it to' do
      workflow = create(:workflow)
      subject = create(:subject)
      other_subject = create(:subject)
  
      create :extract, extractor_key: 's', workflow_id: workflow.id, user_id: 1234, subject_id: subject.id, classification_id: 11111, data: { LN: 1 }
      create :extract, extractor_key: 's', workflow_id: workflow.id, user_id: 1234, subject_id: other_subject.id, classification_id: 22222, data: { LN: 1 }
      create :extract, extractor_key: 's', workflow_id: workflow.id, user_id: 1235, subject_id: subject.id, classification_id: 33333, data: { TGR: 1 }
      create :extract, extractor_key: 's', workflow_id: workflow.id, user_id: 1236, subject_id: subject.id, classification_id: 44444, data: { BR: 1 }
  
      reducer = build(:stats_reducer, key: 's', topic: Reducer.topics[:reduce_by_user], reducible_id: workflow.id, reducible_type: "Workflow")
  
      runner = described_class.new(workflow, [reducer])
      runner.reduce(1234)
  
      expect(UserReduction.count).to eq(1)
      expect(UserReduction.first.user_id).to eq(1234)
      expect(UserReduction.first.data).to eq({"LN" => 2})
    end
  
    context "reducing by project" do
      let(:project) { create :project }
      let(:reducer) { create(:stats_reducer, key: 's', reducible: project) }
      let(:subject) { create(:subject) }
  
      let(:runner) do
        described_class.new(project, [reducer])
      end
  
      it "doesn't try to save user reductions with nil userid" do
        u1 = build :user_reduction, user_id: nil, data: 'missing user id'
        allow(u1).to receive(:save!)
  
        u2 = build :user_reduction, user_id: 3, data: 'user id present'
        allow(u2).to receive(:save!)
  
        runner.persist_reductions([u1, u2])
  
        expect(u1).not_to have_received(:save!)
        expect(u2).to have_received(:save!)
      end
  
      it 'short-circuits the user reducers if there is no user id' do
        fetcher = instance_double(FetchExtractsByUser, extracts: [])
  
        reducible = create :workflow
        reducer = create(:placeholder_reducer,
                          topic: Reducer.topics[:reduce_by_user],
                          reducible: reducible,
                          config: {user_reducer_keys: "testing"}
                        )
        runner = described_class.new(reducible, [reducer])
  
        allow(FetchExtractsByUser).to receive(:new).and_return(fetcher)
        runner.reduce(nil, [])
        expect(fetcher).not_to have_received(:extracts)
      end
    end
  end
  