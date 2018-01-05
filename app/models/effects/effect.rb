module Effects
  class Effect
    attr_reader :config

    def initialize(config = {})
      @config = config
    end

    def valid?
      raise NotImplementedError
    end

    def prepare(workflow_id, subject_id, user_id)
      Action.create!(effect_type: self.class.name.demodulize.underscore,
                     config: config,
                     workflow_id: workflow_id,
                     subject_id: subject_id,
                     user_id: user_id)
    end

    def notify_subscribers(workflow_id, event_name, data)
      workflow = Workflow.find(workflow_id)
      workflow.webhooks.process(event_name, data) if workflow.subscribers?
    end
  end
end
