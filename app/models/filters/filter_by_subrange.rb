module Filters
  class FilterBySubrange < Filter
    include ActiveModel::Validations

    validates :from, numericality: true
    validates :to, numericality: true

    def apply(extract_groups)
      extract_groups[subrange]
    end

    private

    def from
      config[:from] || 0
    end

    def to
      config[:to] || -1
    end

    def subrange
      Range.new(from.to_i, to.to_i)
    end
  end
end