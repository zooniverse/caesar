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
    field :requestedData, RequestedData, property: :requested_data
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

  belongs_to :exportable, polymorphic: true

  def stored_export
    raise "DataRequest needs to be saved to database first" unless id.present?
    @stored_export ||= StoredExport.new("#{id}.csv")
  end

  def url
    return nil unless complete?
    stored_export.download_url
  end

  def as_json(options = {})
    {
      id: id,
      reducible_id: reducible.id,
      reducible_type: reducible_type,
      user_id: user_id,
      subgroup: subgroup,
      status: status,
      requested_data: requested_data,
      url: url,
      updated_at: updated_at.to_s
    }
  end
end
