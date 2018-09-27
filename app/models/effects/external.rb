module Effects
  class External < Effect
    def perform(workflow_id, subject_id)
      # thing goes here
    end

    def valid?
      url.present? && valid_url?
    end

    def self.config_fields
      [:url].freeze
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
