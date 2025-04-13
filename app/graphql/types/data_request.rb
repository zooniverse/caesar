# app/graphql/types/data_request.rb
module Types
    class DataRequest < GraphQL::Schema::Object
      graphql_name 'DataRequest'

      field 'id', ID, null: false
      field 'subgroup', String, null: true
      field 'requestedData', Enums::DataRequestRequestedData, null: true, method: :requested_data
      field 'url', String, null: true
      field 'status', Enums::DataRequestStatus, null: false
    end
  end
