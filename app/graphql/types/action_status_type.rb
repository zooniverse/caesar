Types::ActionStatusType = GraphQL::EnumType.define do
  name "ActionStatus"
  description "Status of a pending or performed action"

  value("pending", "Action is not performed yet")
  value("completed", "Action has been performed successfully")
  value("failed", "Action failed even after retries")
end
