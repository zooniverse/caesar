class Workflow < ApplicationRecord
  Type = GraphQL::ObjectType.define do
    name "Workflow"

    field :id, !types.ID
    field :createdAt, !Types::TimeType, "Timestamp when this workflow was created", property: :created_at
    field :updatedAt, !Types::TimeType, "Timestamp when this workflow was updated", property: :updated_at

    field :extracts, types[Extract::Type] do
      argument :subjectId, !types.ID, "Filter by specific subject"
      argument :extractorKey, types.String, "Filter by specific extractor"

      resolve -> (workflow, args, ctx) {
        scope = Pundit.policy_scope!(ctx[:credential], Extract)
        scope = scope.where(workflow_id: workflow.id)
        scope = scope.where(subject_id: args[:subjectId])
        scope = scope.where(extractor_key: args[:extractorKey]) if args[:extractorKey]
        scope
      }
    end

    field :reductions, types[SubjectReduction::Type] do
      argument :subjectId, !types.ID, "Filter by specific subject"
      argument :reducerKey, types.String, "Filter by specific reducer"

      resolve -> (workflow, args, ctx) {
        scope = Pundit.policy_scope!(ctx[:credential], SubjectReduction)
        scope = scope.where(workflow_id: workflow.id)
        scope = scope.where(subject_id: args[:subjectId])
        scope = scope.where(reducer_key: args[:reducerKey]) if args[:reducerKey]
        scope
      }
    end

    field :subject_reductions, types[SubjectReduction::Type] do
      argument :subjectId, !types.ID, "Filter by specific subject"
      argument :reducerKey, types.String, "Filter by specific reducer"

      resolve -> (workflow, args, ctx) {
        scope = Pundit.policy_scope!(ctx[:credential], SubjectReduction)
        scope = scope.where(workflow_id: workflow.id)
        scope = scope.where(subject_id: args[:subjectId])
        scope = scope.where(reducer_key: args[:reducerKey]) if args[:reducerKey]
        scope
      }
    end

    field :subject_actions, types[SubjectAction::Type] do
      argument :subjectId, !types.ID, "Filter by specific subject"

      resolve -> (workflow, args, ctx) {
        scope = Pundit.policy_scope!(ctx[:credential], Action)
        scope = scope.where(workflow_id: workflow.id)
        scope = scope.where(subject_id: args[:subjectId])
        scope
      }
    end

    field :dataRequests, types[DataRequest::Type] do
      resolve -> (workflow, args, ctx) {
        scope = Pundit.policy_scope!(ctx[:credential], DataRequest)
        scope = scope.where(workflow_id: workflow.id)
        scope
      }
    end
  end

  has_many :extractors
  has_many :reducers, as: :reducible
  has_many :subject_rules
  has_many :user_rules

  has_many :extracts
  has_many :subject_reductions, as: :reducible
  has_many :user_reductions, as: :reducible
  has_many :subject_actions
  has_many :user_actions
  has_many :data_requests, as: :exportable
  
  enum rules_applied: [:all_matching_rules, :first_matching_rule]

  def self.accessible_by(credential)
    return none unless credential.logged_in?
    return none if credential.expired?
    return all if credential.admin?
    return none unless credential.project_ids.present?

    where(project_id: credential.project_ids)
  end

  def subscribers?
    webhooks&.size > 0
  end

  def classification_pipeline
    ClassificationPipeline.new(Workflow,
                               extractors,
                               reducers,
                               subject_rules.rank(:row_order),
                               user_rules.rank(:row_order),
                               rules_applied)
  end

  def webhooks
    Webhooks::Engine.new(webhooks_config)
  end

  def configured?
    (not (extractors&.empty? and reducers&.empty?))
  end

  def public_data?(type)
    case type
    when 'extracts'
      public_extracts?
    when 'reductions'
      public_reductions?
    else
      false
    end
  end

  def subscribers?
    webhooks.size > 0
  end

  def concerns_subjects?
    subject_rules.present? or reducers.where(topic: 'reduce_by_subject').present?
  end

  def concerns_users?
    user_rules.present? or reducers.where(topic: 'reduce_by_user').present?
  end
end
