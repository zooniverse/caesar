require 'spec_helper'

describe ReduceWorker, type: :worker do

  describe '#perform' do
    let(:reducible) { create :project }
    let(:subject) { create :subject }
    let(:reducer) { create(:stats_reducer, key: 's', reducible: reducible) }
    let(:runner) { reducible.reducers_runner }

    it "calls #reduce on the correct pipeline" do
      expect_any_instance_of(RunsReducers).to receive(:reduce).once.with(subject.id, nil, [], {and_check_rules: true})
      described_class.new.perform(reducible.id, reducible.class.to_s, subject.id, nil)
    end

    it 'does reduce when the reducible is active' do
      active_workflow = create :workflow, status: :active

      dbl = instance_double(RunsReducers, reduce: [])
      allow_any_instance_of(IsReducible).to receive(:reducers_runner).and_return(dbl)

      described_class.new.perform(active_workflow.id, active_workflow.class.to_s, subject.id, nil)

      expect(dbl).to have_received(:reduce).once
    end

    it 'does reduce when the reducible is paused' do
      paused_workflow = create :workflow, status: :paused

      dbl = instance_double(RunsReducers, reduce: [])
      allow_any_instance_of(IsReducible).to receive(:reducers_runner).and_return(dbl)

      described_class.new.perform(paused_workflow.id, paused_workflow.class.to_s, subject.id, nil)

      expect(dbl).to have_received(:reduce).once
    end

    it 'does not extract when the reducible is halted' do
      halted_workflow = create :workflow, status: :halted

      dbl = instance_double(RunsReducers, reduce: [])
      allow_any_instance_of(IsReducible).to receive(:reducers_runner).and_return(dbl)

      described_class.new.perform(halted_workflow.id, halted_workflow.class.to_s, subject.id, nil)

      expect(dbl).not_to have_received(:reduce)
    end
  end

  describe '#unique_args' do
    let(:s1) { create :subject }
    let(:s2) { create :subject }

    let(:workflow_subject_only){ create :workflow }
    let(:workflow_user_only){ create :workflow }
    let(:workflow_both){ create :workflow }

    before(:each) do
      ReduceWorker.test_uniq true
    end

    after(:each) do
      ReduceWorker.test_uniq false
    end

    describe 'with default reduction' do
      it 'deduplicates correctly when only subject reducers are present' do
        create :placeholder_reducer, reducible: workflow_subject_only, topic: 0, reduction_mode: 0
        create :placeholder_reducer, reducible: workflow_subject_only, topic: 0, reduction_mode: 0

        expect do
          ReduceWorker.perform_async(workflow_subject_only.id, 'Workflow', s1.id, nil, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_subject_only.id, 'Workflow', s2.id, nil, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_subject_only.id, 'Workflow', s1.id, nil, [5])
        end.not_to change(ReduceWorker.jobs, :size)

        expect do
          ReduceWorker.perform_async(workflow_subject_only.id, 'Workflow', s1.id, nil, [5, 6])
        end.not_to change(ReduceWorker.jobs, :size)

        expect do
          ReduceWorker.perform_async(workflow_subject_only.id, 'Workflow', s1.id, 7, [5])
        end.not_to change(ReduceWorker.jobs, :size)
      end

      it 'deduplicates correctly when only user reducers are present' do
        create :placeholder_reducer, reducible: workflow_user_only, topic: 1, reduction_mode: 0
        create :placeholder_reducer, reducible: workflow_user_only, topic: 1, reduction_mode: 0

        expect do
          ReduceWorker.perform_async(workflow_user_only.id, 'Workflow', nil, 7, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_user_only.id, 'Workflow', nil, 8, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_user_only.id, 'Workflow', nil, 7, [5])
        end.not_to change(ReduceWorker.jobs, :size)

        expect do
          ReduceWorker.perform_async(workflow_user_only.id, 'Workflow', nil, 7, [5, 6])
        end.not_to change(ReduceWorker.jobs, :size)

        expect do
          ReduceWorker.perform_async(workflow_user_only.id, 'Workflow', s1.id, 7, [5])
        end.not_to change(ReduceWorker.jobs, :size)
      end

      it 'deduplicates correctly when both user and subject reducers are present' do
        create :placeholder_reducer, reducible: workflow_both, topic: 0, reduction_mode: 0
        create :placeholder_reducer, reducible: workflow_both, topic: 1, reduction_mode: 0

        expect do
          ReduceWorker.perform_async(workflow_both.id, 'Workflow', nil, 7, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_both.id, 'Workflow', nil, 8, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_both.id, 'Workflow', s1.id, 7, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_both.id, 'Workflow', s1.id, 8, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_both.id, 'Workflow', s2.id, 9, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_both.id, 'Workflow', nil, 7, [5])
        end.not_to change(ReduceWorker.jobs, :size)

        expect do
          ReduceWorker.perform_async(workflow_both.id, 'Workflow', s1.id, 7, [5])
        end.not_to change(ReduceWorker.jobs, :size)

        expect do
          ReduceWorker.perform_async(workflow_both.id, 'Workflow', s1.id, 7, [5,6])
        end.not_to change(ReduceWorker.jobs, :size)
      end
    end

    describe 'with running reduction' do
      it 'deduplicates correctly when only subject reducers are present' do
        create :placeholder_reducer, reducible: workflow_subject_only, topic: 0, reduction_mode: 0
        create :placeholder_reducer, reducible: workflow_subject_only, topic: 0, reduction_mode: 1

        expect do
          ReduceWorker.perform_async(workflow_subject_only.id, 'Workflow', s1.id, nil, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_subject_only.id, 'Workflow', s2.id, nil, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_subject_only.id, 'Workflow', s1.id, nil, [5, 6])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_subject_only.id, 'Workflow', s1.id, nil, [5])
        end.not_to change(ReduceWorker.jobs, :size)

        expect do
          ReduceWorker.perform_async(workflow_subject_only.id, 'Workflow', s1.id, 7, [5])
        end.not_to change(ReduceWorker.jobs, :size)

        expect do
          ReduceWorker.perform_async(workflow_subject_only.id, 'Workflow', s1.id, nil, [5, 6])
        end.not_to change(ReduceWorker.jobs, :size)
      end

      it 'deduplicates correctly when only user reducers are present' do
        create :placeholder_reducer, reducible: workflow_user_only, topic: 1, reduction_mode: 0
        create :placeholder_reducer, reducible: workflow_user_only, topic: 1, reduction_mode: 1

        expect do
          ReduceWorker.perform_async(workflow_user_only.id, 'Workflow', s1.id, 3, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_user_only.id, 'Workflow', s1.id, 4, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_user_only.id, 'Workflow', s1.id, 3, [5, 6])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_user_only.id, 'Workflow', s2.id, 3, [5])
        end.not_to change(ReduceWorker.jobs, :size)

        expect do
          ReduceWorker.perform_async(workflow_user_only.id, 'Workflow', s1.id, 3, [5])
        end.not_to change(ReduceWorker.jobs, :size)

        expect do
          ReduceWorker.perform_async(workflow_user_only.id, 'Workflow', s1.id, 3, [5, 6])
        end.not_to change(ReduceWorker.jobs, :size)
      end

      it 'deduplicates correctly when both reducers are present' do
        create :placeholder_reducer, reducible: workflow_user_only, topic: 0, reduction_mode: 0
        create :placeholder_reducer, reducible: workflow_user_only, topic: 1, reduction_mode: 1

        expect do
          ReduceWorker.perform_async(workflow_user_only.id, 'Workflow', s1.id, 3, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_user_only.id, 'Workflow', s1.id, 4, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_user_only.id, 'Workflow', s2.id, 3, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_user_only.id, 'Workflow', s1.id, 3, [5, 6])
        end.to change(ReduceWorker.jobs, :size).by(1)
      end
    end
  end
end
