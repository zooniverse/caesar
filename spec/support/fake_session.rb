module FakeSession
  def fake_session(admin: false)
    credential = double(Credential, logged_in?: true, admin?: admin, expired?: false)
    allow(controller).to receive(:credential).and_return(credential)
  end
end
