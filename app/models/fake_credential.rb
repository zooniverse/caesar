class FakeCredential
  def login
    'dev'
  end

  def ok?
    true
  end

  def logged_in?
    true
  end

  def expired?
    false
  end

  def admin?
    true
  end

  def accessible_workflow?(workflow)
    workflow
  end
end