class Classification < ApplicationRecord
  belongs_to :workflow
  belongs_to :subject

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
