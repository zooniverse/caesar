# frozen_string_literal: true

# Root for GraphQL queries.
class QueryRoot < GraphQL::Schema::Object
  graphql_name 'QueryRoot'

  field :me, Types::CredentialType, null: true

  def me
    context[:credential]
  end

  field :workflow, Types::WorkflowType, null: true do
    argument :id, ID, required: true
    description 'Find a Workflow by ID'
  end

  def workflow(id:)
    Workflow
      .accessible_by(context[:credential])
      .or(Workflow.where(public_extracts: true))
      .or(Workflow.where(public_reductions: true))
      .find(id)
  end
end
