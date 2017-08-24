class DataRequest < ApplicationRecord
  RequestedData = GraphQL::EnumType.define do
    name "RequestedData"
    description "What type of data is requested"

    value("extracts", "Extracts")
    value("reductions", "Reductions")
  end

  Status = GraphQL::EnumType.define do
    name "Status"
    description "What is the status of this request"

    value("empty", "Nothing to export")
    value("pending", "Request is in the queue to be processed")
    value("processing", "Servers are currently exporting this data")
    value("failed", "Something went wrong while exporting")
    value("complete", "This export is ready to download")
  end

  Type = GraphQL::ObjectType.define do
    name "DataRequest"

    field :id, !types.ID
    field :subgroup, types.String
    field :requested_data, RequestedData
    field :url, types.String
    field :status, !Status
  end

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
