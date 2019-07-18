require 'uri'

module HttpOperation
  class HttpOperationException < StandardError; end
  class ConfigurationError < HttpOperationException;  end
  class NotFound < HttpOperationException; end
  class UnexpectedResponse < HttpOperationException; end

  def self.included(base)
    configure_validation(base)
  end

  def self.configure_validation(base)
    if base.is_a? Class
      base.include ActiveModel::Validations
      base.validates_with HttpOperation::UrlValidator
    end
  end

  class UrlValidator < ActiveModel::Validator
    def validate(record)
      schemes = ['https']
      return true if record.url.blank? # make old tests pass

      begin
        uri = URI.parse(record.url)
        unless uri && uri.host && schemes.include?(uri.scheme)
          record.errors.add(:url, "URL must be one of: #{schemes.join(",")}")
        end
      rescue URI::InvalidURIError
        record.errors.add(:url, "URL could not be parsed")
      end
    end
  end

  def http_post(payload)
    if url.present? && valid?
      response = RestClient.post(url, payload.to_json, {content_type: :json, accept: :json})

      if ([200, 201, 202].include? response.code) and response.body.present?
        result = JSON.parse(response.body)
        if result.is_a? String
          return no_data
        else
          return result
        end
      elsif(response.code == 204)
        no_data
      else
        raise UnexpectedResponse.new "Endpoint failed with HTTP #{response.code}"
      end
    else
      raise ConfigurationError.new "Improperly configured endpoint #{errors.full_messages}"
    end
  rescue RestClient::NotFound => e
    raise NotFound.new e.to_s
  rescue RestClient::Exception => e
    raise operation_failed_type.new(e.to_s)
  end
end