class DataRequest < ApplicationRecord
  EMPTY = 0.freeze
  PENDING = 1.freeze
  PROCESSING = 2.freeze
  FAILED = 3.freeze
  COMPLETE = 4.freeze

  EXTRACTS = 0.freeze
  REDUCTIONS = 1.freeze

  def initialize(attributes={})
    super

    self.status = EMPTY
  end
end
