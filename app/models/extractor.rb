class Extractor < ApplicationRecord
  include Configurable

  def self.of_type(type)
    case type.to_s
    when "blank"
      Extractors::BlankExtractor
    when "external"
      Extractors::ExternalExtractor
    when "question"
      Extractors::QuestionExtractor
    when "survey"
      Extractors::SurveyExtractor
    when "who"
      Extractors::WhoExtractor
    when "pluck_field"
      Extractors::PluckFieldExtractor
    else
      raise "Unknown type #{type}"
    end
  end

  belongs_to :configurable, polymorphic: true

  validates :configurable, presence: true
  validates :key, presence: true, uniqueness: {scope: [:configurable_id]}

  before_validation :nilify_empty_fields

  NoData = Class.new

  def process(classification)
    light = Stoplight("extractor-#{id}") do
      if too_old?(classification)
        NoData
      else
        extract_data_for(classification)
      end
    end

    light.run
  end

  def extract_data_for(classification)
    raise NotImplementedError
  end

  private

  def too_old?(classification)
    return false unless classification.workflow_version.present?
    Gem::Version.new(minimum_workflow_version) > Gem::Version.new(classification.workflow_version)
  end

  def nilify_empty_fields
    self.minimum_workflow_version = nil if minimum_workflow_version.blank?
  end
end
