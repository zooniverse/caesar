class Subject < ApplicationRecord
  def self.update_cache(attributes)
    attributes = attributes.with_indifferent_access if attributes.is_a?(Hash)
    subject = Subject.where(id: attributes[:id]).first_or_initialize
    subject.locations = attributes[:locations] || {}
    subject.metadata = attributes[:metadata]
    subject.save!
  end

  def thumbnail
    location = locations.find do |location|
      location.keys.any? { |mime, url| mime.start_with?("image/") }
    end

    mime, url = location&.find do |mime, url|
      mime.start_with?("image/")
    end

    url
  end
end
