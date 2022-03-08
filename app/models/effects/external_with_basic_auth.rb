module Effects
  class ExternalWithBasicAuth < Effect
    class ExternalEffectFailed < StandardError; end
    class InvalidConfiguration < StandardError; end

    def perform(workflow_id, subject_id)
      raise InvalidConfiguration unless valid?

      reductions = SubjectReduction.where(
        workflow_id: workflow_id,
        subject_id: subject_id,
        reducer_key: reducer_key
      )

      if reductions.length != 1
        raise ExternalEffectFailed, "Incorrect number of reductions found"
      end

      begin
        response = RestClient.post(url, reductions.first.prepare.to_json, {content_type: :json, accept: :json})
      rescue RestClient::InternalServerError
        raise ExternalEffectFailed
      end
    end

    def valid?
      # TOD: this should not be valid unless the basic creds are in the config as well
      reducer_key.present? && url.present? && valid_url?
    end

    def self.config_fields
      [:url, :reducer_key].freeze
    end

    def url
      config[:url]
    end

    def reducer_key
      config[:reducer_key]
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
