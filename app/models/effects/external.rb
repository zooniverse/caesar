module Effects
  class External < Effect
    class ExternalEffectFailed < StandardError; end
    class InvalidConfiguration < StandardError; end

    def perform(workflow_id, subject_id)
      raise InvalidConfiguration unless valid?

      reductions = SubjectReduction.where(
        workflow_id: workflow_id, 
        subject_id: subject_id, 
      )
      reductions = reductions.where(reducer_key: config[:reducer_key]) if config[:reducer_key]

      begin
        response = RestClient.post(url, reductions.to_json, {content_type: :json, accept: :json})
      rescue RestClient::InternalServerError
        raise ExternalEffectFailed
      end
    end

    def valid?
      url.present? && valid_url?
    end

    def self.config_fields
      [:url, :reducer_key].freeze
    end

    def url 
      config[:url]
    end

    def valid_url?
      if url.present?
        begin
          uri = URI.parse(url)
          uri && uri.host && uri.kind_of?(URI::HTTPS)
        rescue URI::InvalidURIError
          false
        end
      else
        false
      end
    end
  end
end
