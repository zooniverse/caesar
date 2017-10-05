module Reducers
  class SummaryStatisticsReducer < Reducer
    attr_reader :extracts

    validate do
      valid_operations = [
        "count",
        "min",
        "max",
        "sum",
        "product",
        "average",
        "stdev"
      ]

      unless config["summarize_field"].present?
        errors.add("summarize_field", "No field specified for operations")
      else
        if config["summarize_field"].ends_with? "."
          errors.add("summarize_field", "Invalid summarize_field specified")
        end
      end

      unless config["operations"].present?
        errors.add("operations", "No operation(s) specified")
      else
        operations = config["operations"]
        unless operations.is_a? Array or operations.is_a? String
          errors.add("operations", "Invalid operations specification")
        else
          if(operations.is_a? String)
            unless valid_operations.include? operations
              errors.add("operations", "Invalid operation '#{operations}'")
            end
          end
          if(operations.is_a? Array)
            if(operations.empty?)
              errors.add("operations", "No operation(s) specified")
            end
            operations.each do |operation|
              unless operation.is_a? String and valid_operations.include? operation
                errors.add("operations", "Invalid operation #{operation}")
              end
            end
          end
        end
      end
    end

    def reduction_data_for(extracts)
      @extracts = extracts
      result = {}

      values = relevant_extracts.map do |extract|
        if extract.data[field_name].present?
          extract.data[field_name].to_f
        else
          nil
        end
      end.select{ |value| not value.nil? }

      if operations.include? "count"
        result["count"] = values.count
      end
      if operations.include? "min"
        result["min"] = values.min
      end
      if operations.include? "max"
        result["max"] = values.max
      end

      result
    end

    private

    def relevant_extracts
      return extracts if extractor_name.blank?
      return extracts.select { |extract| extract.extractor_key == extractor_name }
    end

    def summarize_field
      config['summarize_field']
    end

    def operations
      if config['operations'].is_a? Array
        config['operations']
      else
        [config['operations']]
      end
    end

    def extractor_name
      return nil unless summarize_field.include? "."
      summarize_field.split(".")[0]
    end

    def field_name
      return summarize_field if extractor_name.blank?
      summarize_field.split(".")[1]
    end
  end
end
