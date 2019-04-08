require 'spec_helper'

describe CreatesDataRequests do
  let(:credential) { fake_credential admin: true }
  let(:workflow) { create :workflow }
  let(:project) { create :project }

  let(:obj) { nil }
  let(:args) { {} }
  let(:ctx) { { credential: credential} }

  describe 'for workflows' do
    describe 'extracts' do
      let(:args) { {exportable_id: workflow.id, exportable_type: 'Workflow', requested_data: 'extracts'} }

      it('should produce a data request item for a new request') do
        response = described_class.call(obj, args, ctx)

        expect(response).to be_truthy
        expect(DataRequest.count).to eq(1)
        expect(DataRequest.first.extracts?).to be(true)
      end

      it 'creates public requests when data is public' do
        workflow.update! public_extracts: true
        response = described_class.call(obj, args, ctx)
        expect(response).to be_public
      end

      context 'when not a project collaborator' do
        let(:credential) { fake_credential project_ids: [] }

        it 'allows creating request when workflow exposes extracts publicly' do
          workflow.update! public_extracts: true
          response = described_class.call(obj, args, ctx)
          expect(response).to be_truthy
        end

        it 'fails when workflow does not expose extracts publicly' do
          expect { described_class.call(obj, args, ctx) }.to raise_error(Pundit::NotAuthorizedError)
        end
      end
    end

    describe 'subject_reductions' do
      let(:args) { {exportable_id: workflow.id, exportable_type: 'Workflow', requested_data: 'subject_reductions'} }

      it('should produce reduction requests instead of extract requests') do
        response = described_class.call(obj, args, ctx)

        expect(response).to be_truthy
        expect(DataRequest.count).to eq(1)
        expect(DataRequest.first.subject_reductions?).to be(true)
      end

      context 'when not a project collaborator' do
        let(:credential) { fake_credential project_ids: [] }

        it 'allows creating request when workflow exposes subject_reductions publicly' do
          workflow.update! public_reductions: true
          response = described_class.call(obj, args, ctx)
          expect(response).to be_truthy
        end

        it 'fails when workflow does not expose subject_reductions publicly' do
          expect { described_class.call(obj, args, ctx) }.to raise_error(Pundit::NotAuthorizedError)
        end
      end
    end

    context 'when not a project collaborator' do
      let(:credential) { fake_credential project_ids: [] }
      describe 'user_reductions' do
        let(:args) { {exportable_id: workflow.id, exportable_type: 'Workflow', requested_data: 'user_reductions'} }

        it 'allows creating request when workflow exposes user_reductions publicly' do
          workflow.update! public_reductions: true
          response = described_class.call(obj, args, ctx)
          expect(response).to be_truthy
        end

        it 'fails when workflow does not expose user_reductions publicly' do
          expect { described_class.call(obj, args, ctx) }.to raise_error(Pundit::NotAuthorizedError)
        end
      end
    end
  end

  describe 'for projects' do
    describe 'subject_reductions' do
      let(:args) { {exportable_id: project.id, exportable_type: 'Project', requested_data: 'subject_reductions'} }

      it('should produce reduction requests instead of extract requests') do
        response = described_class.call(obj, args, ctx)

        expect(response).to be_truthy
        expect(DataRequest.count).to eq(1)
        expect(DataRequest.first.subject_reductions?).to be(true)
      end

      context 'when not a project collaborator' do
        let(:credential) { fake_credential project_ids: [] }

        it 'allows creating request when workflow exposes subject_reductions publicly' do
          project.update! public_reductions: true
          response = described_class.call(obj, args, ctx)
          expect(response).to be_truthy
        end

        it 'fails when workflow does not expose subject_reductions publicly' do
          expect { described_class.call(obj, args, ctx) }.to raise_error(Pundit::NotAuthorizedError)
        end
      end
    end

    context 'when not a project collaborator' do
      let(:credential) { fake_credential project_ids: [] }
      describe 'user_reductions' do
        let(:args) { {exportable_id: workflow.id, exportable_type: 'Workflow', requested_data: 'user_reductions'} }
        it 'allows creating request when workflow exposes user_reductions publicly' do
          workflow.update! public_reductions: true
          response = described_class.call(obj, args, ctx)
          expect(response).to be_truthy
        end

        it 'fails when workflow does not expose user_reductions publicly' do
          expect { described_class.call(obj, args, ctx) }.to raise_error(Pundit::NotAuthorizedError)
        end
      end
    end
  end
end
