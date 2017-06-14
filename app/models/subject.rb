class Subject < ApplicationRecord
  def self.update_cache(attributes)
    attributes = attributes.with_indifferent_access if attributes.is_a?(Hash)
    subject = Subject.where(id: attributes[:id]).first_or_initialize
    subject.metadata = attributes[:metadata]
    subject.save!
  end
end
