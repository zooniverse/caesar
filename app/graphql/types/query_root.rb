# app/graphql/types/query_root.rb
module Types
    class QueryRoot < GraphQL::Schema::Object
      graphql_name 'QueryRoot'

      field :me, Types::Credential, null: true do
        description 'Returns the current credential.'
      end

      def me
        context[:credential]
      end

      field :workflow, Types::Workflow, null: true,
            description: 'Find a Workflow by ID' do
        argument :id, ID, required: true
      end

      def workflow(id:)
        Workflow.accessible_by(context[:credential])
          .or(Workflow.where(public_extracts: true))
          .or(Workflow.where(public_reductions: true))
          .find(id)
      end
    end
  end
