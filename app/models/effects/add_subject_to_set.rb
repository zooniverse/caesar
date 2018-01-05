module Effects
  class AddSubjectToSet < Effect
    def perform(workflow_id, subject_id, user_id)
      Effects.panoptes.add_subjects_to_subject_set(subject_set_id, [subject_id])

      notify_subscribers(workflow_id, :subject_added_to_subject_set, {
        "subject_id" => subject_id,
        "subject_set_id" => subject_set_id,
        "workflow_id" => workflow_id
      })
    rescue Panoptes::Client::ServerError => se
      # don't blow up if the subject is already in the subject set;
      # this can happen from time to time and is OK
      raise unless self.class.was_duplicate(se)
    end

    def valid?
      subject_set_id.present?
    end

    def subject_set_id
      config.fetch("subject_set_id")
    end

    def self.was_duplicate(err)
      err.message.include? "PG::UniqueViolation"
    end
  end
end
