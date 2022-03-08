# frozen_string_literal: true

module Effects
  class External < Effect
    class ExternalEffectFailed < StandardError; end
    class InvalidConfiguration < StandardError; end

    attr_reader :workflow_id, :subject_id

    def self.config_fields
      @config_fields ||= %i[url reducer_key].freeze
    end

    def perform(workflow_id, subject_id)
      @workflow_id = workflow_id
      @subject_id = subject_id

      raise InvalidConfiguration unless valid?
      raise ExternalEffectFailed, 'Incorrect number of reductions found' if reductions.length != 1

      post_payload_to_url
    end

    def valid?
      reducer_key.present? && url.present? && valid_url?
    end

    def url
      config[:url]
    end

    def reducer_key
      config[:reducer_key]
    end

    private

    def reductions
      @reductions ||= SubjectReduction.where(
        workflow_id: workflow_id,
        subject_id: subject_id,
        reducer_key: reducer_key
      )
    end

    def reduction_payload
      reductions.first.prepare.to_json
    end

    def valid_url?
      return false unless url.present?

      uri = URI.parse(url)
      uri&.host && uri.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError
      false
    end

    def post_payload_to_url
      RestClient.post(url, reduction_payload, post_request_headers)
    rescue RestClient::InternalServerError
      raise ExternalEffectFailed
    end

    def post_request_headers
      { content_type: :json, accept: :json }
    end
  end
end
