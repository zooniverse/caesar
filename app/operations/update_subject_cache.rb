class UpdateSubjectCache
  attr_reader :attributes

  def initialize(attributes)
    @attributes = attributes.with_indifferent_access
  end

  def perform
    subject = Subject.where(id: attributes[:id]).first_or_initialize
    subject.metadata = attributes[:metadata]
    subject.save!
  end
end
