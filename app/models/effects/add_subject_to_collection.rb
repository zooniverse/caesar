module Effects
  class AddSubjectToCollection < Effect
    def perform(workflow_id, subject_id)
      Effects.panoptes.add_subjects_to_collection(collection_id, [subject_id])
    rescue Panoptes::Client::ServerError => e
      raise unless e.message.include? 'already in the collection'
    end

    def valid?
      collection_id.present?
    end

    def self.config_fields
      [:collection_id].freeze
    end

    def collection_id
      config.fetch("collection_id")
    end
  end
end
