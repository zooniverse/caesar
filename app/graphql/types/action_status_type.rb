module Types
  class ActionStatusType < GraphQL::Schema::Enum
    graphql_name 'ActionStatus'
    description 'Status of a pending or performed action'

    value 'pending', 'Action is not performed yet'
    value 'completed', 'Action has been performed successfully'
    value 'failed', 'Action failed even after retries'
  end
end
