module Configurable
  extend ActiveSupport::Concern

  def load_configuration(config)
    @config = {}

    self.class.configuration_fields.each do |key, options|
      unless config.key?(key) || options.key?(:default)
        raise ArgumentError, "Unconfigured #{key} and no default set" 
      end

      @config[key] = config.key?(key) ? config[key] : options[:default]
    end
  end

  included do
    attr_reader :config
  end

  class_methods do
    def config(key, options = {})
      @configuration_fields ||= {}
      @configuration_fields[key.to_s] = options
    end

    def configuration_fields
      @configuration_fields ||= {}
    end
  end
end
