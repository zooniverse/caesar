class MissingGroupingField < StandardError
  attr_reader :extract_id, :field_name
  def initialize(classification_id, field_name)
    @classification_id = extract_id
    @field_name = field_name
    super("Missing grouping field '#{field_name}' for classification ##{classification_id}")
  end
end

class ExtractGrouping
  attr_reader :extracts, :subgroup

  def initialize(extracts, subgroup)
    @extracts = extracts
    @subgroup = subgroup
  end

  def to_h
    if subgroup.blank? then
      { '_default' => extracts }
    else
      extractor, field = subgroup.split('.')
      extracts_by_classification = group_extracts_by_classification_and_extractor
      validate_key_present extracts_by_classification, extractor, field
      extracts_by_subgroup = group_extracts_by_subgroup(extracts_by_classification, extractor, field)
      flatten_extract_groups(extracts_by_subgroup)
    end
  end

  private

  def validate_key_present(extracts_hash, extractor, field)
      extracts_hash.each do |group|
        raise MissingGroupingField.new(subgroup, group.first[1].classification_id) unless group.key?(extractor)
        raise MissingGroupingField.new(subgroup, group.first[1].classification_id) unless group[extractor].data.key?(field)
      end
  end

  def group_extracts_by_classification_and_extractor
    extracts.group_by { |extract| extract.classification_id }.map do
      |id, classifs| Hash[classifs.map{|classif| [classif.extractor_key, classif]}]
    end
  end

  def group_extracts_by_subgroup(extract_groups, extractor, field)
    extract_groups.group_by { |extract_hash| extract_hash[extractor].data[field] }
  end

  def flatten_extract_groups(extract_groups)
    Hash[ extract_groups.map { |subg, ex| [subg, ex.map(&:values).flatten] } ]
  end
end
