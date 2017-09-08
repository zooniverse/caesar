class Extractor < ApplicationRecord
  belongs_to :workflow

  validates :workflow, presence: true

  NoData = Class.new

  def process(classification)
    return NoData if too_old?(classification)
    extract_data_for(classification)
  end

  def extract_data_for(classification)
    raise NotImplementedError
  end

  private

  def too_old?(classification)
    Gem::Version.new(minimum_workflow_version) > Gem::Version.new(classification.workflow_version)
  end
end
