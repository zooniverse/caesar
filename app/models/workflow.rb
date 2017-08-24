class Workflow < ApplicationRecord
  Type = GraphQL::ObjectType.define do
    name "Workflow"

    field :id, !types.ID
    field :created_at, !Types::TimeType, "Timestamp when this workflow was created"
    field :updated_at, !Types::TimeType, "Timestamp when this workflow was updated"

    field :extracts, types[Extract::Type] do
      argument :subject_id, !types.ID, "Filter by specific subject"
      argument :extractor_id, types.String, "Filter by specific extractor"

      resolve -> (workflow, args, ctx) {
        scope = workflow.extracts
        scope = scope.where(subject_id: args[:subject_id])
        scope = scope.where(extractor_id: args[:extractor_id]) if args[:extractor_id]
        scope
      }
    end

    field :reductions, types[Reduction::Type] do
      argument :subject_id, !types.ID, "Filter by specific subject"

      resolve -> (workflow, args, ctx) {
        workflow.reductions.where(subject_id: args[:subject_id])
      }
    end

    field :actions, types[Action::Type] do
      argument :subject_id, !types.ID, "Filter by specific subject"

      resolve -> (workflow, args, ctx) {
        workflow.actions.where(subject_id: args[:subject_id])
      }
    end

    field :data_requests, types[DataRequest::Type] do
      resolve -> (workflow, args, ctx) {
        workflow.data_requests
      }
    end
  end

  has_many :extracts
  has_many :reductions
  has_many :actions

  def self.accessible_by(credential)
    return none unless credential.logged_in?
    return none if credential.expired?
    return all if credential.admin?
    return none unless credential.project_ids.present?

    where(project_id: credential.project_ids)
  end

  has_many :data_requests
  has_many :extracts
  has_many :reductions
  has_many :actions

  def subscribers?
    webhooks&.size > 0
  end

  def classification_pipeline
    ClassificationPipeline.new(extractors, reducers, rules)
  end

  def extractors
    Extractors::FromConfig.build_many(extractors_config)
  end

  def reducers
    Reducers::FromConfig.build_many(reducers_config)
  end

  def rules
    Rules::Engine.new(rules_config)
  end

  def webhooks
    Webhooks::Engine.new(webhooks_config)
  end

  def configured?
    (not (extractors&.empty? and reducers&.empty?)) and
      (rules&.present? and subscribers?)
  end

  def subscribers?
    webhooks.size > 0
  end

end
