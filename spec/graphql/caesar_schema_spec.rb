require 'rails_helper'

describe CaesarSchema do
  let(:credential) { build :credential }
  let(:context) { {credential: credential} }
  let(:variables) { {} }
  let(:result) {
    described_class.execute(
      query_string,
      context: context,
      variables: variables
    )
  }

  describe 'getting data for a workflow' do
    let(:workflow) { create :workflow }
    let(:query_string) do <<-END
      {workflow(id:#{workflow.id}) {id}}
    END
    end

    context 'when there is no current user' do
      it 'is nil' do
        expect { result }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'returns a workflow' do
        workflow.update! public_extracts: true
        expect(result["data"]["workflow"]).to eq("id" => workflow.id.to_s)
      end
    end

    context 'for a user with access' do
      let(:credential) { build :credential, workflows: [workflow] }

      it 'returns a workflow' do
        expect(result["data"]["workflow"]).to eq("id" => workflow.id.to_s)
      end
    end

    context 'with public extracts' do
      let(:subject) { create :subject }
      let(:workflow) { create :workflow, public_extracts: true }

      let(:query_string) do <<-END
        {
          workflow(id: #{workflow.id}) {
            extracts(subjectId: #{subject.id}) { data }
            subject_reductions(subjectId: #{subject.id}) { data }
          }
        }
      END
      end

      it 'exposes extracts when not logged in' do
        create :extract, workflow: workflow, subject: subject, data: {a: 1}
        expect(result["data"]["workflow"]["extracts"].size).to eq(1)
      end

      it 'does not expose reductions when not logged in' do
        create :subject_reduction, reducible: workflow, subject: subject, data: {a: 1}
        expect(result["data"]["workflow"]["subject_reductions"].size).to eq(0)
      end
    end

    context 'with public reductions' do
      let(:subject) { create :subject }
      let(:workflow) { create :workflow, public_reductions: true }

      let(:query_string) do <<-END
        {
          workflow(id: #{workflow.id}) {
            extracts(subjectId: #{subject.id}) { data }
            subject_reductions(subjectId: #{subject.id}) { data }
          }
        }
      END
      end

      it 'exposes reductions when not logged in' do
        create :subject_reduction, reducible: workflow, subject: subject, data: {a: 1}
        expect(result["data"]["workflow"]["subject_reductions"].size).to eq(1)
      end

      it 'does not expose extracts when not logged in' do
        create :extract, workflow: workflow, subject: subject, data: {a: 1}
        expect(result["data"]["workflow"]["extracts"].size).to eq(0)
      end
    end
  end
end
