module Types
  class DataRequestType < GraphQL::Schema::Object
    graphql_name 'DataRequest'

    field :id, ID, null: false
    field :subgroup, String, null: true
    field :requestedData, Types::RequestedDataEnum, null: true, method: :requested_data
    field :url, String, null: true
    field :status, Types::DataRequestStatusEnum, null: false
  end
end
