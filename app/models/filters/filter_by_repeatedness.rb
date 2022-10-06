module Filters
  class FilterByRepeatedness < Filter
    include ActiveModel::Validations

    REPEATED_CLASSIFICATIONS = ["keep_first", "keep_last", "keep_all"]
    validates :repeated_classifications, inclusion: {in: REPEATED_CLASSIFICATIONS}

    def apply(extract_groups)
      case repeated_classifications
      when "keep_all"
        extract_groups
      when "keep_first"
        keep_first_user_classification(extract_groups)
      when "keep_last"
        keep_last_user_classification(extract_groups)
      end
    end

    private

    def keep_last_user_classification(extract_groups)
      # reverse the list so we can use the same logic as keep_first
      only_last_classifications = keep_first_user_classification(extract_groups.reverse)
      # preserve the sort order of the original extract groups
      only_last_classifications.reverse
    end

    def keep_first_user_classification(extract_groups)
      # track the subjects a user has classified across the extract groups (different / duplicate classifications)
      subjects_user_has_classified = {}
      filtered_extract_groups = extract_groups.select do |extracts_from_single_classification|
        uniq_user_classifications_per_subject(subjects_user_has_classified, extracts_from_single_classification)
      end
      filtered_extract_groups.to_a
    end

    def uniq_user_classifications_per_subject(subjects_user_has_classified, extracts_from_single_classification)
      user_id = extracts_from_single_classification.user_id
      return true if user_id.nil? # keep all anonymous classifications

      subject_id = extracts_from_single_classification.subject_id

      subjects_user_has_classified[subject_id] ||= Set.new
      user_ids_that_have_classified_subject = subjects_user_has_classified[subject_id]

      # skip the extract if we've already got one for this user id
      return false if user_ids_that_have_classified_subject.include?(extracts_from_single_classification.user_id)

      user_ids_that_have_classified_subject << extracts_from_single_classification.user_id
      true # keep the extract and record the associated user for next lookup
    end

    def repeated_classifications
      @config["repeated_classifications"] || "keep_first"
    end
  end
end
