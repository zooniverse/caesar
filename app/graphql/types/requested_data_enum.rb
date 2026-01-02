# frozen_string_literal: true

module Types
  # Enum describing which data is requested for export.
  class RequestedDataEnum < GraphQL::Schema::Enum
    graphql_name 'RequestedData'
    description 'What type of data is requested'

    value 'extracts', 'Extracts'
    value 'reductions', 'Reductions'
    value 'subject_reductions', 'Subject Reductions'
    value 'user_reductions', 'User Reductions'
  end
end
