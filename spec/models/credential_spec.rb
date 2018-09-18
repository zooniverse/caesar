require 'spec_helper'

describe Credential, type: :model do
  let(:panoptes) {
    instance_double(
      Panoptes::Client,
      workflow: nil
    )
  }

  let(:credential) do
    credential = Credential.create! expires_at: DateTime.new, token: '', project_ids: [1, 2, 3, 4]
    allow(credential).to receive(:client).and_return(panoptes)
    allow(credential).to receive(:admin?).and_return(false)
    credential
  end

  it 'defaults expires_at to the date in the token' do
    pending
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzUxMiJ9.eyJkYXRhIjp7ImlkIjoxMzIzODY5LCJsb2dpbiI6Im1hcnRlbnpvb25pdmVyc2UiLCJkbmFtZSI6Im1hcnRlbnpvb25pdmVyc2UiLCJzY29wZSI6WyJ1c2VyIiwicHJvamVjdCIsImdyb3VwIiwiY29sbGVjdGlvbiIsImNsYXNzaWZpY2F0aW9uIiwic3ViamVjdCIsIm1lZGl1bSIsIm9yZ2FuaXphdGlvbiIsInB1YmxpYyJdLCJhZG1pbiI6dHJ1ZX0sImV4cCI6MTQ5OTY4ODM1NCwiaXNzIjoicGFuLXN0YWciLCJybmciOiJiNmZkIn0.OSKeTRiS_ITbQhqYNbmFzIFc8zZ8nuSEjnlR1GGZtgPCQ3x9BoTq-NATN-fnFm9BQm5fseK2k4HMRixedtY2KFi0-Wq7gXBylzKQBc0He9nrnYX3e8TfXjq7X6RhllWVY7XpQRSyJKyq8Rc6gqro2bLSP2faaTDOV8kfsZYGNhWtXB28zLrkt2v_EEfikm3-i3PjFhr06le8mQDZPYt28cKan8KXr_cLV2lbSHVADE6ogpOQhYMbWUOLFqh1zgzgRRQFJY8byvv8HsVdh2KQlG1P0F2NOn5CfhbM5huUG0ktxmQosmVLmpEk_gafmhYn2GMA3JWHy4B_HoM437wk9s5voosfMXeZ6KY8R2d03VyXPIqlNnk5Mtqa0W_POSsx2mgI2QnfAJBLjU1bJU3LXRuaFe2asMfZ2rwji44DlfDefo5Fclh4_ZVSivcrktPx3WPJQShTQnxXkz6F5KoioEoPmDGCONieNGRKOFYsE9OYUn8Zr_Tk6QpuEUZ4tdnoRil9pJEzk18klEXRSCjsIs-CEdFJ3zCIO_anOyy7I2_njLPA_GfJLWVvVBhTCfVUkViPIKCNZgAUu57uhTVv1tk8vz943s_G-lw7TF5E-X_8qbae_L0vFeLvLpOI2xkgMXEB24OrISv8tYYjbUyPx4uwnWT4WCiSIMRHrsPFMHk"

    # Above token is from staging, so stub out the correct environment
    allow_any_instance_of(Credential).to receive(:panoptes_client_env).and_return("staging")

    credential = Credential.create!(token: token)
    expect(credential.expires_at).to eq(Time.at(1499688354))
  end

  describe 'accessible objects' do
    describe 'when not admin' do
      it 'allows access to projects' do
        expect(credential.accessible_project? 1).to be(true)
      end

      it 'prevents access to projects' do
        expect(credential.accessible_project? 5).to be(false)
      end

      it 'allows access to workflows' do
        allow(panoptes).to receive(:workflow).and_return({"links"=>{"project"=>3}})
        result = credential.accessible_workflow? 1
        expect(result).not_to be(nil)
        expect(result["project_id"]).to eq(3)
      end

      it 'prevents access to workflows' do
        allow(panoptes).to receive(:workflow).and_return(nil)
        expect(credential.accessible_workflow? 1).to be(nil)

        allow(panoptes).to receive(:workflow).and_raise(Panoptes::Client::ResourceNotFound)
        expect(credential.accessible_workflow? 1).to be(nil)
      end
    end

    describe 'when admin' do
      it 'allows access to projects' do
        allow(credential).to receive(:admin?).and_return(true)
        expect(credential.accessible_project? 1).to be(true)
        expect(credential.accessible_project? 5).to be(true)
      end

      it 'allows access to workflows' do
        allow(credential).to receive(:admin?).and_return(true)
        allow(panoptes).to receive(:workflow).and_return({"links"=>{"project"=>3}})
        expect(credential.accessible_workflow? 1).not_to be(nil)
        expect(credential.accessible_workflow?(1)["project_id"]).to eq(3)

        allow(panoptes).to receive(:workflow).and_return(nil)
        expect(credential.accessible_workflow? 1).not_to be(nil)

        allow(panoptes).to receive(:workflow).and_raise(Panoptes::Client::ResourceNotFound)
        expect(credential.accessible_workflow? 1).not_to be(nil)
      end
    end
  end
end
