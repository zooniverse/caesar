class ExtractGrouping
  attr_reader :extracts, :subgroup

  def initialize(extracts, subgroup)
    @extracts = extracts
    @subgroup = subgroup
  end

  def to_h
    do_grouping()
  end

  private

  def do_grouping
    if subgroup.blank? then
      { '_default' => extracts }
    else
      extracts.group_by {|extract| extract[subgroup]}
    end
  end
end
