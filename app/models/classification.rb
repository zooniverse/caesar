class Classification
  attr_reader :attributes

  def initialize(attributes = {})
    @attributes = attributes
  end

  def id
    attributes.fetch("id")
  end

  def annotations
    @annotations ||= attributes.fetch("annotations", {})
                               .group_by { |ann| ann["task"] }
  end

  def project_id
    attributes.fetch("links").fetch("project")
  end

  def workflow_id
    attributes.fetch("links").fetch("workflow")
  end

  def user_id
    attributes.fetch("links").fetch("user")
  end

  def subject_id
    attributes.fetch("links").fetch("subjects").first
  end
end
