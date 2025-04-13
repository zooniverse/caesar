# app/graphql/types/workflow.rb
module Types
    class Workflow < GraphQL::Schema::Object
      graphql_name 'Workflow'

      field :id, ID, null: false
      field :createdAt, Types::TimeType, null: false,
        description: 'Timestamp when this workflow was created', method: :created_at
      field :updatedAt, Types::TimeType, null: false,
        description: 'Timestamp when this workflow was updated', method: :updated_at

      field :extracts, [Types::Extract], null: true do
        argument :subjectId, ID, required: true, description: 'Filter by specific subject'
        argument :extractorKey, String, required: false, description: 'Filter by specific extractor'
      end
      def extracts(subjectId:, extractorKey: nil)
        scope = Pundit.policy_scope!(context[:credential], Extract)
        scope = scope.where(workflow_id: object.id)
        scope = scope.where(subject_id: subjectId)
        scope = scope.where(extractor_key: extractorKey) if extractorKey
        scope
      end

      field :reductions, [Types::SubjectReduction], null: true do
        argument :subjectId, ID, required: true, description: 'Filter by specific subject'
        argument :reducerKey, String, required: false, description: 'Filter by specific reducer'
      end
      def reductions(subjectId:, reducerKey: nil)
        scope = Pundit.policy_scope!(context[:credential], SubjectReduction)
        scope = scope.where(workflow_id: object.id)
        scope = scope.where(subject_id: subjectId)
        scope = scope.where(reducer_key: reducerKey) if reducerKey
        scope
      end

      field :subject_reductions, [Types::SubjectReduction], null: true do
        argument :subjectId, ID, required: true, description: 'Filter by specific subject'
        argument :reducerKey, String, required: false, description: 'Filter by specific reducer'
      end
      def subject_reductions(subjectId:, reducerKey: nil)
        reductions(subjectId: subjectId, reducerKey: reducerKey)
      end

      field :subject_actions, [Types::SubjectReduction], null: true do
        argument :subjectId, ID, required: true, description: 'Filter by specific subject'
      end
      def subject_actions(subjectId:)
        scope = Pundit.policy_scope!(context[:credential], SubjectAction)
        scope = scope.where(workflow_id: object.id)
        scope = scope.where(subject_id: subjectId)
        scope
      end

      field :user_reductions, [Types::UserReduction], null: true do
        argument :userId, ID, required: true, description: 'Filter by specific user'
        argument :reducerKey, String, required: false, description: 'Filter by specific reducer'
      end
      def user_reductions(userId:, reducerKey: nil)
        scope = Pundit.policy_scope!(context[:credential], UserReduction)
        scope = scope.where(workflow_id: object.id)
        scope = scope.where(user_id: userId)
        scope = scope.where(reducer_key: reducerKey) if reducerKey
        scope
      end

      field :user_actions, [Types::UserAction], null: true do
        argument :userId, ID, required: true, description: 'Filter by specific user'
      end
      def user_actions(userId:)
        scope = Pundit.policy_scope!(context[:credential], UserAction)
        scope = scope.where(workflow_id: object.id)
        scope = scope.where(user_id: userId)
        scope
      end

      field :dataRequests, [Types::DataRequest], null: true do
      end
      def dataRequests
        scope = Pundit.policy_scope!(context[:credential], DataRequest)
        scope.where(workflow_id: object.id)
      end
    end
  end
