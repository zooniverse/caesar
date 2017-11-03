module FakeSession
  def fake_session(admin: false, logged_in: true)
    @credential = instance_double(Credential, logged_in?: logged_in, admin?: admin, ok?: true, expired?: false, project_ids: [])
    allow(controller).to receive(:credential).and_return(@credential)
  end
end
