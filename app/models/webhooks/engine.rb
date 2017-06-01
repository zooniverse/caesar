module Webhooks
  class Engine
    def initialize(hooks_config)
      @hooks = Array.wrap(hooks_config).map do |hook_config|
        Hook.new(hook_config['endpoint'], hook_config['events'] || [])
      end
    end

    def process(event_type, data)
      @hooks.each { |hook| hook.process(event_type, data) }
    end

    def size
      @hooks.size
    end
  end
end
