module Extractors
  class SqsExtractor < Extractor
    config_field :queue_name, default: nil
    config_field :queue_url, default: nil

    validate do
      if queue_name.blank? && queue_url.blank?
        errors.add("Please specify either queue name or queue url")
      end
    end

    def extract_data_for(classification)
      sqs_client.send_message(queue_url: queue_url, message_body: classification.to_json)

      "dispatched"
    end

    def sqs_client
      @sqs ||= Aws::SQS::Client.new
    end

    def queue_name
      @queue_name = config['queue_name']
    end

    def queue_url
      @queue_url = config['queue_url'] || sqs_client.get_queue_url(queue_name: queue_name).queue_url
    end
  end
end