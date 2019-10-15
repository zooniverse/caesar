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

  it 'gets the user id from a JWT' do
    # generate a keypair to build a sample JWT
    rsa_private = OpenSSL::PKey::RSA.generate 2048
    rsa_public = rsa_private.public_key

    # encode a fake app state
    contents = { data: {id: 3}, exp: (Time.now + 1.minute).to_i }
    token = JWT.encode contents, rsa_private, 'RS512'

    # use our public key for decryption instead of the default one
    allow_any_instance_of(Panoptes::Client).to receive(:jwt_signing_public_key).and_return(rsa_public)

    credential = Credential.create!(token: token)
    expect(credential.user_id).to eq(3)
  end

  it 'defaults expires_at to the date in the token' do
    expiry_time = Time.at(1499688354)
    panoptes_client = instance_double('Panoptes::Client')
    allow(panoptes_client).to receive(:token_expiry).and_return(expiry_time)
    credential = Credential.new(token: 'fake_token_string')
    allow(credential).to receive(:client).and_return(panoptes_client)
    credential.save
    expect(credential.expires_at).to eq(expiry_time)
  end

  describe 'accessible objects' do
    describe 'when not admin' do
      it 'allows access to projects' do
        expect(credential.accessible_project? 1).to be(true)
      end

      it 'allows access to projects with string ids' do
        expect(credential.accessible_project?("1")).to be_truthy
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
      end

      it 'denies access to workflows that are not real' do
        allow(panoptes).to receive(:workflow).and_return(nil)
        expect(credential.accessible_workflow? 1).to be(nil)

        allow(panoptes).to receive(:workflow).and_raise(Panoptes::Client::ResourceNotFound)
        expect(credential.accessible_workflow? 1).to be(nil)
      end
    end
  end
end
