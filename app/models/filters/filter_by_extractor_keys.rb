module Filters
  class FilterByExtractorKeys < Filter
    def apply(extract_groups)
      return extract_groups if extractor_keys.blank?

      extract_groups.map do |extract_group|
        extract_group.select do |extract|
          extractor_keys.include?(extract.extractor_key)
        end
      end
    end

    private

    def extractor_keys
      Array.wrap(@config["extractor_keys"] || [])
    end
  end
end