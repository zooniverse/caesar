class Subject < ApplicationRecord
  def self.maybe_create_subject(subject_id, reducible)
    return nil if Subject.exists?(subject_id)

    project_id = if reducible.respond_to? :project_id
      reducible.project_id
    else
      reducible.id
    end

    # only allow access if subject belongs to specified project
    subject = panoptes_api.subject_in_project? subject_id, project_id

    if !subject.blank?
      Subject.create id: subject_id.to_i, metadata: subject['metadata']
    end
  end

  def self.update_cache(attributes)
    tries ||= 2

    transaction do
      attributes = attributes.with_indifferent_access if attributes.is_a?(Hash)
      subject = Subject.where(id: attributes[:id]).first_or_initialize
      subject.metadata = attributes[:metadata]
      subject.save!
      subject
    end
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    sleep 2
    retry unless (tries-=1).zero?
    raise
  end

  def additional_subject_ids_for_reduction
    if metadata["previous_subject_ids"]
      JSON.parse(metadata["previous_subject_ids"])
    else
      []
    end
  end

  private

  def self.panoptes_api
    Effects.panoptes
  end
end
