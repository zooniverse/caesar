require 'spec_helper'

describe CreatesDataRequests do
  let(:credential) { build :credential, admin: true }
  let(:workflow) { create :workflow }

  let(:obj) { nil }
  let(:args) { {} }
  let(:ctx) { { credential: credential} }

  describe 'extracts' do
    let(:args) { {workflow_id: workflow.id, requested_data: 'extracts'} }

    it('should produce a data request item for a new request') do
      response = described_class.call(obj, args, ctx)

      expect(response).to be_truthy
      expect(DataRequest.count).to eq(1)
      expect(DataRequest.first.extracts?).to be(true)
    end

    context 'when not a project collaborator' do
      let(:credential) { build :credential, workflows: [] }

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

  describe 'reductions' do
    let(:args) { {workflow_id: workflow.id, requested_data: 'reductions'} }

    it('should produce reduction requests instead of extract requests') do
      response = described_class.call(obj, args, ctx)

      expect(response).to be_truthy
      expect(DataRequest.count).to eq(1)
      expect(DataRequest.first.reductions?).to be(true)
    end

    context 'when not a project collaborator' do
      let(:credential) { build :credential, workflows: [] }

      it 'allows creating request when workflow exposes reductions publicly' do
        workflow.update! public_reductions: true
        response = described_class.call(obj, args, ctx)
        expect(response).to be_truthy
      end

      it 'fails when workflow does not expose reductions publicly' do
        expect { described_class.call(obj, args, ctx) }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
