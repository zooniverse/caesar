QueryRoot = GraphQL::ObjectType.define do
  name "QueryRoot"

  field :workflow do
    type Workflow::Type
    argument :id, !types.ID
    description "Find a Workflow by ID"
    resolve ->(obj, args, ctx) {
      Workflow.accessible_by(ctx[:credential])
        .or(Workflow.where(public_extracts: true))
        .or(Workflow.where(public_reductions: true))
        .find(args["id"])
    }
  end
end
