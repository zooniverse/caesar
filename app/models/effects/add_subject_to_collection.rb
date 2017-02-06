module Effects
  class AddSubjectToCollection < Effect
    def perform(workflow_id, subject_id)
      Effects.panoptes.add_subjects_to_collection(collection_id, [subject_id])
    end

    def collection_id
      config.fetch("collection_id")
    end
  end
end
