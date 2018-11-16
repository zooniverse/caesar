module Filters
  class FilterByEmptiness < Filter
    include ActiveModel::Validations

    EMPTY_EXTRACTS = ["keep_all", "ignore_empty"]

    validates :empty_extracts, inclusion: {in: EMPTY_EXTRACTS}

    def apply(extract_groups)
      case empty_extracts
      when "keep_all"
        extract_groups
      when "ignore_empty"
        extract_groups.map do |extract_group|
          extract_group.select { |extract| extract.data.present? }
        end
      end
    end

    private

    def empty_extracts
      @config["empty_extracts"] || "keep_all"
    end
  end
end