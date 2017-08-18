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

  validates :status, presence: true
  validates :requested_data, presence: true

  belongs_to :workflow

  def as_json(options)
    {
      workflow_id: workflow_id,
      user_id: user_id,
      subgroup: subgroup,
      status: status,
      requested_data: requested_data,
      url: url
    }
  end
end
