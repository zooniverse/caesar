module Reducers
  class SqsReducer < Reducer
    config_field :queue_name, default: nil
    config_field :queue_url, default: nil

    validate do
      if queue_name.blank? && queue_url.blank?
        errors.add("Please specify either a queue name or a queue url")
      end
    end

    def reduce_into(extracts, reduction)
      extracts.map do |extract|
        {
          "message_deduplication_id" => extract.id,
          "message_body" => prepare_extract(extract).to_json,
          "queue_url" => queue_url
        }
      end.each do |message|
        sqs_client.send_message(message)
      end

      reduction.tap do |r|
        r.data ||= "dispatched"
      end
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

    def prepare_extract(extract)
      extract.attributes.except("classification_id", "created_at", "updated_at", "extractor_key", "workflow_id")
    end
  end
end