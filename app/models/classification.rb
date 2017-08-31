class Classification
  attr_reader :attributes

  def initialize(attributes = {})
    @attributes = attributes
  end

  def id
    attributes.fetch('id')
  end

  def created_at
    attributes.fetch('created_at', nil)
  end

  def updated_at
    attributes.fetch('updated_at', attributes.fetch('created_at', nil))
  end

  def annotations
    @annotations ||= attributes.fetch('annotations', {})
                               .group_by { |ann| ann['task'] }
  end

  def metadata
    attributes.fetch('metadata', {})
  end

  def project_id
    attributes.fetch('links').fetch('project').to_i
  end

  def workflow_id
    attributes.fetch('links').fetch('workflow').to_i
  end

  def workflow_version
    attributes.fetch('workflow_version', nil)
  end

  def user_id
    attributes.fetch('links')['user']&.to_i
  end

  def subject_id
    attributes.fetch('links').fetch('subjects').first.to_i
  end

  def gold_standard
    attributes.fetch('gold_standard', nil)
  end

  def expert_classifier
    attributes.fetch('expert_classifier', nil)
  end

  def as_json(_options)
    {
      id: id,
      project_id: project_id,
      workflow_id: workflow_id,
      workflow_version: workflow_version,
      subject_id: subject_id,
      user_id: user_id,
      annotations: annotations,
      metadata: metadata,
      gold_standard: gold_standard,
      expert_classifier: expert_classifier,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end
