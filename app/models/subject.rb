class Subject < ApplicationRecord
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
end
