module FakeSession
  def fake_session(attributes = {})
    attributes = attributes.with_indifferent_access.reverse_merge(login: 'tester', admin: false)
    current_user = CurrentUser.new(attributes)

    allow(controller).to receive(:current_user).and_return(current_user)
  end
end
