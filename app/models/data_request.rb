class DataRequest < ApplicationRecord
  PENDING = 0.freeze
  PROCESSING = 1.freeze
  FAILED = 2.freeze
  COMPLETE = 3.freeze

  EXTRACTS = 0.freeze
  REDUCTIONS = 1.freeze
end
