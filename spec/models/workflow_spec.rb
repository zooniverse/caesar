require 'rails_helper'

RSpec.describe Workflow, type: :model do
  let(:workflow) { create :workflow }
  let(:subject) { create :subject }

  describe 'public_data?' do
    describe 'public extracts' do
      it 'is true' do
        workflow.public_extracts = true
        expect(workflow.public_data?("extracts")).to be_truthy
      end

      it 'is false' do
        workflow.public_extracts = false
        expect(workflow.public_data?("extracts")).to be_falsey
      end
    end

    describe 'public reductions' do
      it 'is true' do
        workflow.public_reductions = true
        expect(workflow.public_data?("subject_reductions")).to be_truthy
      end

      it 'is false' do
        workflow.public_reductions = false
        expect(workflow.public_data?("subject_reductions")).to be_falsey
      end
    end

    it 'is false for any other data type' do
      expect(workflow.public_data?("foobar")).to be_falsey
    end
  end

  describe 'stoplight_status' do
    let(:classification) { create :classification, subject: subject, workflow: workflow }
    let(:extractor) { create :extractor, workflow: workflow, type: Extractors::ExternalExtractor }
    let(:reducer) { create :reducer, workflow_id: workflow.id, type: Reducers::ExternalReducer }

    it 'should be an hash with relevant arrays' do
      stoplight_status = workflow.stoplight_status

      expect(stoplight_status).to be_a(Hash)

      expected_keys = [
        :failed_extractors,
        :failed_reducers,
        :failed_subject_rules,
        :failed_user_rules
      ]
      expect(stoplight_status.keys).to match_array(expected_keys)

      expected_keys.each do |key|
        expect(stoplight_status[key]).to be_a(Array)
      end
    end

    describe 'success' do
      it 'include empty array for successful extractor' do
        allow(extractor).to receive(:extract_data_for).and_return(nil)

        extractor.process(classification)

        stoplight_status = workflow.stoplight_status
        expect(stoplight_status[:failed_extractors].size).to eq(0)
      end

      it 'include empty array for successful reducers' do
        extract = create :extract, workflow_id: reducer.workflow_id, classification_id: classification.id, subject: subject, data: { 'foo' => 'bar' }

        extracts = [extract]
        reduction_fetcher = instance_double(SubjectReductionFetcher, retrieve: SubjectReduction.new)
        allow(reducer).to receive(:reduce_into).and_return(nil)

        reducer.process(extracts, reduction_fetcher)

        stoplight_status = workflow.stoplight_status
        expect(stoplight_status[:failed_reducers].size).to eq(0)
      end

      it 'include empty array for successful subject rules' do
        subject_rule = create :subject_rule, workflow: workflow

        allow(subject_rule).to receive_message_chain(:condition, :apply).and_return(true)

        subject_rule.process(subject.id, [])

        stoplight_status = workflow.stoplight_status
        expect(stoplight_status[:failed_subject_rules].size).to eq(0)
      end

      it 'include empty array for successful user rules' do
        user_rule = create :user_rule, workflow: workflow

        allow(user_rule).to receive_message_chain(:condition, :apply).and_return(true)

        user_rule.process(subject.id, [])

        stoplight_status = workflow.stoplight_status
        expect(stoplight_status[:failed_user_rules].size).to eq(0)
      end
    end

    describe 'failure' do
      it 'includes details of failed extractors' do
        allow(extractor).to receive(:extract_data_for) { raise 'failure' }

        3.times do
          expect { extractor.process(classification) }.to raise_error('failure')
        end

        stoplight_status = workflow.stoplight_status
        expect(stoplight_status[:failed_extractors].size).to eq(1)
        extractor_item = stoplight_status[:failed_extractors].first
        expect(extractor_item.id).to eq(extractor.id)
      end

      it 'includes details of failed reducers' do
        wf = Workflow.find(reducer.workflow_id)
        extract = create :extract, workflow_id: reducer.workflow_id, classification_id: classification.id, subject: subject, data: { 'foo' => 'bar' }

        extracts = [extract]
        reduction_fetcher = instance_double(SubjectReductionFetcher, retrieve: SubjectReduction.new)
        allow(reducer).to receive(:reduce_into) { raise 'failure' }

        3.times do
          expect { reducer.process(extracts, reduction_fetcher) }.to raise_error('failure')
        end

        stoplight_status = wf.stoplight_status
        expect(stoplight_status[:failed_reducers].size).to eq(1)
        reducer_item = stoplight_status[:failed_reducers].first
        expect(reducer_item.id).to eq(reducer.id)
      end

      it 'includes details of failed subject rules' do
        subject_rule = create :subject_rule, workflow: workflow

        allow(subject_rule).to receive_message_chain(:condition, :apply).and_raise('failure')

        3.times do
          expect { subject_rule.process(subject.id, []) }.to raise_error('failure')
        end

        stoplight_status = workflow.stoplight_status
        expect(stoplight_status[:failed_subject_rules].size).to eq(1)
        subject_rule_item = stoplight_status[:failed_subject_rules].first
        expect(subject_rule.id).to eq(subject_rule_item.id)
      end

      it 'includes details of failed user rules' do
        user_rule = create :user_rule, workflow: workflow

        allow(user_rule).to receive_message_chain(:condition, :apply).and_raise('failure')

        3.times do
          expect { user_rule.process(subject.id, []) }.to raise_error('failure')
        end

        stoplight_status = workflow.stoplight_status
        expect(stoplight_status[:failed_user_rules].size).to eq(1)
        user_rule_item = stoplight_status[:failed_user_rules].first
        expect(user_rule.id).to eq(user_rule_item.id)
      end
    end
  end

  describe 'cached counters' do
    it 'increments the extract count when new extracts are added' do
      Extract.create! workflow_id: workflow.id, subject_id: subject.id, classification_id: 12345, classification_at: DateTime.now, extractor_key: 'key'
      expect(Workflow.find(workflow.id).extracts_count).to eq(1)
      Extract.create! workflow_id: workflow.id, subject_id: subject.id, classification_id: 12346, classification_at: DateTime.now, extractor_key: 'key'
      expect(Workflow.find(workflow.id).extracts_count).to eq(2)
    end

    it 'increments the subject reduction count when new reductions are added' do
      SubjectReduction.create! reducible: workflow, subject_id: subject.id, reducer_key: 'key'
      expect(Workflow.find(workflow.id).subject_reductions_count).to eq(1)
    end

    it 'increments the user reduction count when new reductions are added' do
      UserReduction.create! reducible: workflow, user_id: 12345, reducer_key: 'key'
      expect(Workflow.find(workflow.id).user_reductions_count).to eq(1)
    end

    it 'increments the subject action count when new actions are added' do
      SubjectAction.create! workflow_id: workflow.id, subject_id: subject.id, effect_type: 'retire_subject'
      expect(Workflow.find(workflow.id).subject_actions_count).to eq(1)
    end

    it 'increments the user action count when new actions are added' do
      UserAction.create! workflow_id: workflow.id, user_id: 12345, effect_type: 'promote_user'
      expect(Workflow.find(workflow.id).user_actions_count).to eq(1)
    end
  end

  describe 'rerun_extractors', sidekiq: :fake do
    it 'enqueues jobs' do
      create_list(:extract, 3, workflow: workflow)
      workflow.rerun_extractors
      expect(FetchClassificationsWorker.jobs.size).to eq(3)
    end

    it 'fetches classifications each known subject' do
      extracts = create_list(:extract, 3, workflow: workflow)
      for_subject = FetchClassificationsWorker.fetch_for_subject

      expect(FetchClassificationsWorker).to receive(:perform_in).with(anything, workflow.id, extracts[0].subject_id, for_subject)
      expect(FetchClassificationsWorker).to receive(:perform_in).with(anything, workflow.id, extracts[1].subject_id, for_subject)
      expect(FetchClassificationsWorker).to receive(:perform_in).with(anything, workflow.id, extracts[2].subject_id, for_subject)

      workflow.rerun_extractors
    end
  end

  describe 'rerun_reducers', sidekiq: :fake do
    context 'if there are subject rules' do
      before { create :subject_rule, workflow: workflow }
      before { create :placeholder_reducer, :reduce_by_subject, reducible: workflow }

      it 'reruns reducers for each subject' do
        extracts = create_list(:extract, 3, workflow: workflow)
        extract = create(:extract, workflow: workflow, subject_id: extracts[2].subject_id)

        expect(ReduceWorker).to receive(:perform_in).with(anything, workflow.id, 'Workflow', extracts[0].subject_id, nil, [extracts[0].id])
        expect(ReduceWorker).to receive(:perform_in).with(anything, workflow.id, 'Workflow', extracts[1].subject_id, nil, [extracts[1].id])
        expect(ReduceWorker).to receive(:perform_in).with(anything, workflow.id, 'Workflow', extracts[2].subject_id, nil, [extracts[2].id, extract.id])
        workflow.rerun_reducers
      end
    end

    context 'if there are user rules' do
      before { create :user_rule, workflow: workflow }
      before { create :placeholder_reducer, :reduce_by_user, reducible: workflow }

      it 'reruns reducers for each user' do
        extract1 = create(:extract, workflow: workflow, user_id: 1)
        extract2 = create(:extract, workflow: workflow, user_id: 2)
        extract3 = create(:extract, workflow: workflow, user_id: 2)
        extract4 = create(:extract, workflow: workflow, user_id: nil)

        expect(ReduceWorker).to receive(:perform_in).with(anything, workflow.id, 'Workflow', nil, 1, [extract1.id])
        expect(ReduceWorker).to receive(:perform_in).with(anything, workflow.id, 'Workflow', nil, 2, [extract2.id, extract3.id])
        expect(ReduceWorker).not_to receive(:perform_in).with(anything, workflow.id, 'Workflow', nil, nil, anything)
        workflow.rerun_reducers
      end
    end
  end

  describe 'IsReducible' do
    it 'can re-run reducers' do
      expect{workflow.rerun_reducers}.not_to raise_error
    end
  end

  describe 'as_json' do
    it 'includes stoplight status' do
      expect(workflow.as_json).to have_key(:stoplight_status)
    end
  end
end
