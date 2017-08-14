class DataRequest < ApplicationRecord
  enum status: {
    empty: 0,
    pending: 1,
    processing: 2,
    failed: 3,
    complete: 4
  }

  enum requested_data: {
    extracts: 0,
    reductions: 1
  }
end
