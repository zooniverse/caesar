QueryRoot = GraphQL::ObjectType.define do
  name "QueryRoot"

  field :workflow do
    type Types::WorkflowType
    argument :id, !types.ID
    description "Find a Workflow by ID"
    resolve ->(obj, args, ctx) {
      Workflow.accessible_by(ctx[:credential]).find(args["id"])
    }
  end
end
