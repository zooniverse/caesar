class DataRequest < ApplicationRecord
  class DataRequestCanceled < StandardError; end
  RequestedData = GraphQL::EnumType.define do
    name "RequestedData"
    description "What type of data is requested"

    value("extracts", "Extracts")
    value("reductions", "Reductions")
    value("subject_reductions", "Subject Reductions")
    value("user_reductions", "User Reductions")
  end

  Status = GraphQL::EnumType.define do
    name "Status"
    description "What is the status of this request"

    value("empty", "Nothing to export")
    value("pending", "Request is in the queue to be processed")
    value("processing", "Servers are currently exporting this data")
    value("failed", "Something went wrong while exporting")
    value("complete", "This export is ready to download")
    value("canceling", "This export is being canceled")
    value("canceled", "This export has been canceled")
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
    complete: 4,
    canceling: 11,
    canceled: 12
  }

  enum requested_data: {
    extracts: 0,
    subject_reductions: 1,
    user_reductions: 2
  }

  validates :status, presence: true
  validates :requested_data, presence: true

  belongs_to :exportable, polymorphic: true

  def stored_export
    raise "DataRequest needs to be saved to database first" unless id.present?
    @stored_export ||= StoredExport.new("#{id}.csv")
  end

  def simple?
    user_id.nil? && subgroup.nil?
  end

  def url
    return nil unless complete?
    stored_export.download_url
  end

  def as_json(options = {})
    {
      id: id,
      exportable_id: exportable.id.to_s,
      exportable_type: exportable.class.to_s,
      user_id: user_id,
      subgroup: subgroup,
      status: status,
      requested_data: requested_data,
      url: url,
      updated_at: updated_at.to_s
    }
  end
end
