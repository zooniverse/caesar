module Effects
  class AddSubjectToCollection < Effect
    def perform(workflow_id, subject_id)
      @stoplight_id = "add-subject-to-collection-#{workflow_id}-#{subject_id}"
      light = Stoplight(@stoplight_id) do
        Effects.panoptes.add_subjects_to_collection(collection_id, [subject_id])
      end
      light.run
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
      config.fetch('collection_id', nil)
    end
  end
end
