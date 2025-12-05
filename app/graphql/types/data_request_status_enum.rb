module Types
  class DataRequestStatusEnum < GraphQL::Schema::Enum
    graphql_name 'Status'
    description 'What is the status of this request'

    value 'empty', 'Nothing to export'
    value 'pending', 'Request is in the queue to be processed'
    value 'processing', 'Servers are currently exporting this data'
    value 'failed', 'Something went wrong while exporting'
    value 'complete', 'This export is ready to download'
    value 'canceling', 'This export is being canceled'
    value 'canceled', 'This export has been canceled'
  end
end
