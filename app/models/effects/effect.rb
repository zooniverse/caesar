module Effects
  class Effect
    attr_reader :config

    def initialize(config = {})
      @config = config
    end

    def prepare(workflow_id, subject_id)
      Action.create!(effect_type: self.class.name.demodulize.underscore,
                     config: config,
                     workflow_id: workflow_id,
                     subject_id: subject_id)
    end
  end
end
