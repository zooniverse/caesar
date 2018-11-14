module Filters
  class FilterBySubrange < Filter
    def apply(extract_groups)
      extract_groups.sort_by(&:classification_at)[subrange]
    end

    private

    def from
      (@config["from"] || 0).to_i
    end

    def to
      (@config["to"] || -1).to_i
    end

    def subrange
      Range.new(from, to)
    end
  end
end