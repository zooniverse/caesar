DataRequestType = GraphQL::EnumType.define do
  name "RequestedData"
  description "What type of data is requested"

  value("extracts", "Extracts")
  value("reductions", "Reductions")
end

DataRequestStatus = GraphQL::EnumType.define do
  name "Status"
  description "What is the status of this request"

  value("empty", "Nothing to export")
  value("pending", "Request is in the queue to be processed")
  value("processing", "Servers are currently exporting this data")
  value("failed", "Something went wrong while exporting")
  value("complete", "This export is ready to download")
end

Types::DataRequestType = GraphQL::ObjectType.define do
  name "DataRequest"

  field :id, !types.ID
  field :subgroup, types.String
  field :requested_data, DataRequestType
  field :url, types.String
  field :status, !DataRequestStatus
end
