class CurrentUser
  attr_reader :attributes

  def initialize(attributes)
    @attributes = attributes
  end

  def logged_in?
    attributes["login"].present?
  end

  def login
    attributes.fetch("login")
  end

  def admin?
    attributes.fetch("admin") || false
  end
end
