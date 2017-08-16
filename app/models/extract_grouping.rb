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

      # group extracts by classification; then within each classification group,
      # turn the extracts into a hash keyed by extractor id
      extracts_by_classification = extracts.group_by { |extract| extract.classification_id }.map do
        |id, classifs| Hash[classifs.map{|classif| [classif.extractor_id, classif]}]
      end

      extracts_by_classification.each do |group|
        raise MissingGroupingField.new(subgroup, group.first[1].classification_id) unless group.key?(extractor)
        raise MissingGroupingField.new(subgroup, group.first[1].classification_id) unless group[extractor].data.key?(field)
      end

      # group the extract groups by the value of "extractor_id.field_name" specified in subgroup param,
      # then flatten each of these groups into a basic list
      Hash[
        extracts_by_classification.group_by{|nest| nest[extractor].data[field]}.map do |subg, ex|
          [subg, ex.map{|x| x.map{|k,v| pluck_data_key v, field}}.flatten] end
      ]
    end
  end

  private

  def pluck_data_key(extract, key)
    extract.tap do |extr|
      extr.data.except!(key)
    end
  end
end
