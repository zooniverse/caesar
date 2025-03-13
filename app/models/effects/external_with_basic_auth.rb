# frozen_string_literal: true

module Effects
  class ExternalWithBasicAuth < External
    def self.config_fields
      @config_fields ||= %i[url reducer_key username password].freeze
    end

    def valid?
      super && username.present? && password.present?
    end

    def username
      config[:username]
    end

    def password
      config[:password]
    end

    private

    def post_payload_to_url
      light = Stoplight("external-with-basic-auth-#{@workflow_id}-#{@subject_id}") do
        options = {
          body: reduction_payload,
          basic_auth: { username: username, password: password },
          headers: post_request_headers
        }
        response = HTTParty.post(url, options)
        # success is a 200, 201 or 204 response code - allow some leeway with the target endpoint
        return response if response.ok? || response.created? || response.no_content?

        raise ExternalEffectFailed
      end
      light.run
    end

    def post_request_headers
      { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    end
  end
end
