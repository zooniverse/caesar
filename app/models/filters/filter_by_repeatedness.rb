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
      subjects_user_has_classified = Hash.new

      extract_groups.select do |extracts_from_single_classification|
        subject_id = extracts_from_single_classification.subject_id
        user_id = extracts_from_single_classification.user_id

        subjects_user_has_classified[subject_id] ||= Set.new
        user_ids_that_have_classified_subject = subjects_user_has_classified[subject_id]

        case
        when extracts_from_single_classification.user_id.nil?
          true # keep anonymous classifications
        when user_ids_that_have_classified_subject.include?(user_id)
          false # skip the extract if we've already got one for this user id
        else
          user_ids_that_have_classified_subject << user_id
          true # keep the extract and record the associated user for next lookup
        end
      end.to_a
    end

    def repeated_classifications
      @config["repeated_classifications"] || "keep_first"
    end
  end
end
