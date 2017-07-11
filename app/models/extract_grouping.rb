class MissingGroupingField < StandardError
  attr_reader :extract_id, :field_name
  def initialize(extract_id, field_name)
    @extract_id = extract_id
    @field_name = field_name
    super("Missing grouping field '#{field_name}' in extract ##{extract_id}")
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
      extracts.group_by do |extract|
        raise MissingGroupingField.new(extract.id, subgroup) unless extract.data&.key?(subgroup)
        extract.data[subgroup]
      end
    end
  end
end
