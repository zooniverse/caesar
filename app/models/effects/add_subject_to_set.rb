module Effects
  class AddSubjectToSet < Effect
    def perform(workflow_id, subject_id)
      light = Stoplight("add-to-subject-set-#{workflow_id}-#{subject_id}") do
        Effects.panoptes.add_subjects_to_subject_set(subject_set_id, [subject_id])
      end
      light.run
    rescue Panoptes::Client::ServerError => se
      # don't blow up if the subject is already in the subject set;
      # this can happen from time to time and is OK
      raise unless self.class.was_duplicate(se)
    end

    def valid?
      subject_set_id.present?
    end

    def self.config_fields
      [:subject_set_id].freeze
    end

    def subject_set_id
      config.fetch('subject_set_id', nil)
    end

    def self.was_duplicate(err)
      err.message.include? "PG::UniqueViolation"
    end
  end
end
