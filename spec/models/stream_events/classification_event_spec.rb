require 'spec_helper'

describe StreamEvents::ClassificationEvent do
  let(:queue) { double(add: nil) }
  let(:stream) { double(KinesisStream, queue: queue) }

  context 'when workflow is not present' do
    let(:hash) do
      {
        "data" => ActionController::Parameters.new(
          build(:classification_event, workflow_id: 99999, subject: double(id: 123))
        ),
        "linked" => {"subjects" => [{"id" => "123"}]}
      }
    end

    it 'does not process' do
      described_class.new(stream, hash).process
      expect(queue).not_to have_received(:add)
    end
  end

  context 'when workflow exists' do
    let(:workflow) { create :workflow }
    let(:hash) do
      {
        "data" => ActionController::Parameters.new(
          build(:classification_event, workflow: workflow, subject: double(id: 123))
        ),
        "linked" => {"subjects" => [{"id" => "123"}]}
      }
    end

    context 'when workflow has no extractors' do
      it 'does not process' do
        described_class.new(stream, hash).process
        expect(queue).not_to have_received(:add)
      end
    end

    context 'when workflow is paused or halted' do
      it 'does not process' do
        create :survey_extractor, workflow: workflow

        workflow.paused!
        described_class.new(stream, hash).process
        expect(queue).not_to have_received(:add)

        workflow.halted!
        described_class.new(stream, hash).process
        expect(queue).not_to have_received(:add)
      end

      it 'does not upsert a classification when the workflow is halted' do
        workflow.halted!
        expect(Classification).not_to receive(:upsert)

        described_class.new(stream, hash).process
      end
    end

    context 'when workflow has custom queue' do
      it 'records the custom queue if one is configured' do
        workflow.update(custom_queue_name: 'custom')
        create :survey_extractor, workflow: workflow
        described_class.new(stream, hash).process
        expect(queue).to have_received(:add).once.with(ExtractWorker, 'custom', any_args)
      end
    end

    context 'when workflow has extractors' do
      context 'when all extractors are internal' do
        it 'processes an event with the internal queue' do
          create :survey_extractor, workflow: workflow
          described_class.new(stream, hash).process
          expect(queue).to have_received(:add).once.with(ExtractWorker, any_args)
        end
      end

      context 'when workflow has external extractors' do
        it 'processes an event with the external queue' do
          create :external_extractor, workflow: workflow
          described_class.new(stream, hash).process
          expect(queue).to have_received(:add).once.with(ExtractWorkerExternal, any_args)
        end
      end
    end
  end
end
