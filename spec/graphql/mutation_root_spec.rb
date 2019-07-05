require 'spec_helper'

describe MutationRoot do
  let(:credential) { fake_credential admin: true }
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
      mutation { createDataRequest(exportableId: #{workflow.id}, exportableType: "Workflow", requestedData: extracts) { id } }
    END
    end

    #TODO: we should probably test this for project owners as well
    it 'creates data requests' do
      expect(result["data"]["createDataRequest"]["id"]).to eq(DataRequest.first.id)
    end
  end
end
