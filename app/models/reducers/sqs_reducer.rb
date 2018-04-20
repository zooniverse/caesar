module Reducers
  class SqsReducer < Reducer
    config_field :queue_name, default: nil
    config_field :queue_url, default: nil

    def reduce_into(extracts, reduction)
      extracts.map do |extract|
        { "id" => extract.id, "message_body" => prepare_extract(extract).to_json }
      end.tap do |message_list|
        sqs_client.send_message_batch({
          queue_url: queue_url,
          entries: message_list
        })
      end

      reduction.tap do |r|
        r.data ||= "dispatched"
      end
    end

    def sqs_client
      @sqs ||= Aws::SQS::Client.new
    end

    def queue_name
      config['queue_name']
    end

    def queue_url
      config['queue_url'] || sqs_client.get_queue_url(queue_name: queue_name).queue_url
    end

    def prepare_extract(extract)
      extract.attributes.except("classification_id", "created_at", "updated_at", "extractor_key", "workflow_id")
    end
  end
end