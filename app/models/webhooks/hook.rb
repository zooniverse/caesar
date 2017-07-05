module Webhooks
  class Hook
    attr_reader :endpoint, :events

    def initialize(endpoint, events)
      @endpoint = endpoint
      @events = events
    end

    def process(event_name, data)
      return unless configured? and (subscribed? event_name)
      NotifyWebhookWorker.perform_async(endpoint, event_name, data)
    end

    def configured?
      return (not (endpoint.nil? or endpoint.empty?))
    end

    def subscribed?(event_name)
      return (events.nil? or events.empty? or events.include? event_name)
    end
  end
end
