module Effects
  class AddSubjectToSet < Effect
    def perform(workfow_id, subject_id)
      Effects.panoptes.add_subjects_to_subject_set(subject_set_id, [subject_id])
    end

    def subject_set_id
      config.fetch("subject_set_id")
    end
  end
end
