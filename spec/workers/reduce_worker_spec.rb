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
          ReduceWorker.perform_async(workflow_subject_only.id, 'Workflow', s1, nil, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_subject_only.id, 'Workflow', s2, nil, [5])
        end.to change(ReduceWorker.jobs, :size).by(1)

        expect do
          ReduceWorker.perform_async(workflow_subject_only.id, 'Workflow', s1, nil, [5])
        end.not_to change(ReduceWorker.jobs, :size)

        expect do
          ReduceWorker.perform_async(workflow_subject_only.id, 'Workflow', s1, nil, [5, 6])
        end.not_to change(ReduceWorker.jobs, :size)

        expect do
          ReduceWorker.perform_async(workflow_subject_only.id, 'Workflow', s1, 7, [5])
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
