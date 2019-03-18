module FakeSession
  def fake_session(admin: false, logged_in: true, project_ids: [], user_id: nil, expired: false)
    credential = fake_credential(admin: admin, logged_in: logged_in, project_ids: project_ids, user_id: user_id)
    allow(controller).to receive(:credential).and_return(credential)
    credential
  end

  def stub_credential(method, arguments: nil, result: nil)
    invoke = allow(controller.send :credential).to receive(method)
    invoke.with(*arguments) unless arguments.nil?
    invoke.and_return(result) unless result.nil?
    # allow(controller.send :credential).to receive(method).and_return(result)
  end

  def fake_credential(admin: false, logged_in: true, project_ids: [], user_id: nil, expired: false)
    instance_double(
      Credential,
      authenticate!: logged_in,
      logged_in?: logged_in,
      admin?: admin,
      expired?: expired,
      user_id: user_id,
      project_ids: project_ids
    )
  end
end
