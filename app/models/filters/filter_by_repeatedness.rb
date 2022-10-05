module Filters
  class FilterByRepeatedness < Filter
    include ActiveModel::Validations

    REPEATED_CLASSIFICATIONS = ["keep_first", "keep_last", "keep_all"]
    validates :repeated_classifications, inclusion: {in: REPEATED_CLASSIFICATIONS}

    def apply(extract_groups)
      ordered_extract_groups = extract_groups.sort_by(&:classification_at)
      case repeated_classifications
      when "keep_all"
        extract_groups
      when "keep_first"
        keep_first_classification(ordered_extract_groups)
      when "keep_last"
        keep_first_classification(ordered_extract_groups.reverse).reverse
      end
    end

    private
    def keep_first_classification(extracts)
      subjects ||= Hash.new

      extracts.select do |extracts_for_classification|
        subject_id = extracts_for_classification.subject_id
        user_id = extracts_for_classification.user_id

        subjects[subject_id] = Set.new unless subjects.has_key? subject_id
        id_list = subjects[subject_id]

        next true unless extracts_for_classification.user_id
        next false if id_list.include?(user_id)
        id_list << user_id
        true
      end.to_a
    end

    def repeated_classifications
      @config["repeated_classifications"] || "keep_first"
    end
  end
end