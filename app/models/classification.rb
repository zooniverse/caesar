class Classification
  attr_reader :attributes

  def initialize(attributes = {})
    @attributes = attributes
  end

  def annotations
    @annotations ||= attributes.fetch("annotations", {})
                               .group_by { |ann| ann["task"] }
  end
end
