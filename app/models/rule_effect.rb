class RuleEffect < ApplicationRecord
  belongs_to :rule

  enum action: [:retire_subject, :add_subject_to_set, :add_subject_to_collection]

  validates :action, presence: true, inclusion: {in: RuleEffect.actions.keys}

  def prepare(workflow_id, subject_id)
    Action.create!(effect_type: action,
                   config: config,
                   workflow_id: workflow_id,
                   subject_id: subject_id)
  end

  def notify_subscribers(workflow_id, event_name, data)
    workflow = Workflow.find(workflow_id)
    workflow.webhooks.process(event_name, data) if workflow.subscribers?
  end
end
