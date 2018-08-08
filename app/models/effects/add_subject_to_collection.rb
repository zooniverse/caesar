module Effects
  class AddSubjectToCollection < Effect
    def perform(workflow_id, subject_id)
      Effects.panoptes.add_subjects_to_collection(collection_id, [subject_id])

      notify_subscribers(workflow_id, :subject_added_to_collection, {
        "subject_id" => subject_id,
        "collection_id" => collection_id,
        "workflow_id" => workflow_id
      })
    end

    def valid?
      collection_id.present?
    end

    def self.config_fields
      ["collection_id"]
    end

    def collection_id
      config.fetch("collection_id")
    end
  end
end
