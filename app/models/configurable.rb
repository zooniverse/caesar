module Configurable
  extend ActiveSupport::Concern

  class_methods do
    def config_field(key, options = {})
      @configuration_fields ||= {}
      @configuration_fields[key] = options

      validates key, presence: {allow_nil: (options.key?(:default) && options[:default].nil?)}

      if options.key?(:enum)
        validates key, inclusion: {in: options[:enum]}
      end

      define_method key do
        if options.key?(:default)
          config.fetch(key.to_s, options[:default])
        else
          config[key.to_s]
        end
      end

      define_method :"#{key}=" do |value|
        if value.present?
          self.config[key.to_s] = value
        else
          self.config.delete(key.to_s)
        end
      end
    end

    def merge_configuration_fields
      if self.superclass.respond_to? :merge_configuration_fields
        self.configuration_fields.merge self.superclass.merge_configuration_fields
      else
        self.configuration_fields
      end
    end

    def configuration_fields
      @configuration_fields ||= {}
    end
  end
end
