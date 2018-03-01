class Classification < ApplicationRecord
  belongs_to :configurable, polymorphic: true
  belongs_to :subject

  validates :configurable, presence: true

  def self.upsert(data)
    classification = Classification.find_or_initialize_by(id: data.fetch("id"))
    classification.annotations = data.fetch("annotations")
    classification.metadata = data.fetch("metadata")
    classification.workflow_version = data.fetch("workflow_version")
    classification.created_at = data.fetch("created_at")
    classification.updated_at = data.fetch("updated_at")
    classification.links = data.fetch("links")
    classification.tap(&:save!)
  end

  def annotations=(val)
    write_attribute(:annotations,
                    val.group_by { |ann| ann['task'] })
  end

  def workflow_version
    metadata.fetch('workflow_version', nil)
  end

  def links=(hash)
    if hash["project"].present?
      self.project_id = hash["project"]
    end

    if hash["workflow"].present?
      self.workflow_id = hash["workflow"]
    end

    if hash["subjects"].present?
      self.subject_id = hash["subjects"][0]
    end

    if hash["user"].present?
      self.user_id = hash["user"].to_i
    end
  end

  def prepare
    {
      id: id,
      project_id: project_id,
      workflow_id: workflow_id,
      workflow_version: workflow_version,
      subject_id: subject_id,
      user_id: user_id,
      annotations: annotations,
      metadata: metadata,
      subject: subject.attributes,
      created_at: created_at,
      updated_at: updated_at
    }.with_indifferent_access
  end

  def as_json(_options)
    prepare
  end
end
