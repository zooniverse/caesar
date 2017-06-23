module FakeSession
  def fake_session(admin: false)
    current_user = double(CurrentUser, logged_in?: true, admin?: admin)
    allow(controller).to receive(:current_user).and_return(current_user)
  end
end
