require 'spec_helper'

describe MutationRoot do
  let(:credential) { build :credential, admin: true }
  let(:context) { {credential: credential} }
  let(:variables) { {} }
  let(:result) {
    CaesarSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
  }

  describe 'createDataRequest' do
    let(:workflow) { create :workflow }
    let(:mutation_string) do <<-END
      mutation { createDataRequest(workflowId: #{workflow.id}, requestedData: extracts) { id } }
    END
    end

    it 'creates data requests' do
      expect(result["data"]["createDataRequest"]["id"]).to eq(DataRequest.first.id)
    end
  end
end
