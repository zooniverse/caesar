module FakeSession
  def fake_session(admin: false, logged_in: true, project_ids: [], current_user_id: nil)
    @credential = instance_double(Credential,
                                  logged_in?: logged_in,
                                  admin?: admin,
                                  ok?: true,
                                  expired?: false,
                                  current_user_id: current_user_id,
                                  project_ids: project_ids)

    allow(controller).to receive(:credential).and_return(@credential)
  end
end
