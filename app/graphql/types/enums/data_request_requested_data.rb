# app/graphql/types/enums/data_request_requested_data.rb
module Types
  module Enums
    class DataRequestRequestedData < GraphQL::Schema::Enum
      graphql_name 'RequestedData'
      description 'What type of data is requested'

      value 'extracts', 'Extracts'
      value 'reductions', 'Reductions'
      value 'subject_reductions', 'Subject Reductions'
      value 'user_reductions', 'User Reductions'
    end
  end
end
