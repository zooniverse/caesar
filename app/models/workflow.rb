class Workflow < ApplicationRecord
  include IsReducible

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
        scope = Pundit.policy_scope!(ctx[:credential], SubjectAction)
        scope = scope.where(workflow_id: workflow.id)
        scope = scope.where(subject_id: args[:subjectId])
        scope
      }
    end

    field :user_reductions, types[UserReduction::Type] do
      argument :userId, !types.ID, "Filter by specific user"
      argument :reducerKey, types.String, "Filter by specific reducer"

      resolve -> (workflow, args, ctx) {
        scope = Pundit.policy_scope!(ctx[:credential], UserReduction)
        scope = scope.where(workflow_id: workflow.id)
        scope = scope.where(user_id: args[:userId])
        scope = scope.where(reducer_key: args[:reducerKey]) if args[:reducerKey]
        scope
      }
    end

    field :user_actions, types[UserAction::Type] do
      argument :userId, !types.ID, "Filter by specific subject"

      resolve -> (workflow, args, ctx) {
        scope = Pundit.policy_scope!(ctx[:credential], UserAction)
        scope = scope.where(workflow_id: workflow.id)
        scope = scope.where(user_id: args[:userId])
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
  enum status: { paused: 0, active: 1 }

  attr_accessor :rerun

  def self.accessible_by(credential)
    return none unless credential.logged_in?
    return none if credential.expired?
    return all if credential.admin?
    return none unless credential.project_ids.present?

    where(project_id: credential.project_ids)
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

  def extractors_runner
    RunsExtractors.new(extractors)
  end

  def rerun_extractors
    subject_ids = extracts.pluck(:subject_id).uniq

    # allow up to 100 rerun jobs per minute
    duration = (subject_ids.count / 100.0).ceil.minutes

    subject_ids.each do |subject_id|
      FetchClassificationsWorker.perform_in(rand(duration.to_i).seconds, id, subject_id, FetchClassificationsWorker.fetch_for_subject)
    end
  end

  def last_n_subjects(n, source)
    source.last(n*5).pluck(:subject_id).uniq.last(n)
  end

  def random_n_subjects(n)
    (extracts.pluck(:subject_id).sample(n*3) + subject_reductions.pluck(:subject_id).sample(n*3)).uniq.sample(n)
  end
end
