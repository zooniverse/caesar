module Reducers
  class SummaryStatisticsReducer < Reducer
    config_field :summarize_field
    config_field :operations

    attr_reader :extracts

    @@valid_operations = [
      "count",
      "min",
      "max",
      "sum",
      "product",
      "mean",
      "sse",
      "variance",
      "stdev",
      "first",
      "median",
      "mode"
    ]

    validate do
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
            unless @@valid_operations.include? operations
              errors.add("operations", "Invalid operation '#{operations}'")
            end
          end
          if(operations.is_a? Array)
            if(operations.empty?)
              errors.add("operations", "No operation(s) specified")
            end
            operations.each do |operation|
              unless operation.is_a? String and @@valid_operations.include? operation
                errors.add("operations", "Invalid operation #{operation}")
              end
            end
          end
        end
      end
    end

    def reduce_into(extracts, reduction)
      @old_store = reduction.store || {}
      @new_store = {}

      @extracts = extracts

      hash = {}.tap do |result|
        operations.each do |operation|
          if @@valid_operations.include? operation
            result[operation] = self.send(operation)
          end
        end
      end

      reduction.tap do |r|
        r.store = @new_store
        r.data = hash
      end
    end

    private

    def count
      @count = values.count + get_store("count", 0) unless @count.present?

      set_store("count", @count)
      @count
    end

    def min
      unless @min.present?
        old_min = get_store("min", nil)
        new_min = values.min
        @min = if old_min.blank? then new_min elsif old_min < new_min then old_min else new_min end
      end

      set_store("min", @min)
      @min
    end

    def max
      unless @max.present?
        old_max = get_store("max", nil)
        new_max = values.max
        @max = if old_max.blank? then new_max elsif old_max > new_max then old_max else new_max end
      end

      set_store("max", @max)
      @max
    end

    def first
      @first = get_store("first", nil) || values.first unless @first.present?

      set_store("first", @first)
      @first
    end

    def sum
      @sum = values.reduce(:+) + get_store("sum", 0) unless @sum.present?

      set_store("sum", @sum)
      @sum
    end

    def product
      @product = values.reduce(:*) * get_store("product", 1) unless @product.present?

      set_store("product", @product)
      @product
    end

    def mean
      @mean ||= if sum.blank? then nil elsif count.blank? then nil else sum / count end

      set_store("mean", @mean)
      @mean
    end

    def sse
      unless @sse.present?
        local_sse = get_store("sse", 0)

        # perform online computation to update SSE without old values present
        # online SSE algorithm given by https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Online_algorithm
        local_count = get_store("count", 0)
        local_mean = get_store("mean", 0)

        values.each do |new_value|
          local_count = local_count + 1
          delta = new_value - local_mean
          local_mean = local_mean + (delta / local_count)
          delta2 = new_value - local_mean
          local_sse = local_sse + (delta * delta2)
        end

        # store intermediate values if they weren't already being computed
        set_store("count", count) unless @new_store.key?("count")
        set_store("mean", mean) unless @new_store.key("mean")

        @sse = local_sse
      end

      set_store("sse", @sse)
      @sse
    end

    def variance
      @variance ||= if sse.blank? then nil elsif count < 2 then nil else sse / (count-1) end

      set_store("variance", @variance)
      @variance
    end

    def stdev
      @stdev ||= if variance.blank? then nil else Math.sqrt(variance) end
      @stdev
    end

    def median
      @median ||= if count < 1 then nil else (sorted_values[(count - 1) / 2] + sorted_values[count / 2]) / 2.0 end
      @median
    end

    def mode
      unless @mode.present?
        @mode = frequencies.sort_by{|k, count| count}.last.first.to_f
      end

      set_store("mode", @mode)
      @mode
    end

    def frequencies
      unless @frequencies.present?
        old_freqs = get_store("frequencies", {})
        new_freqs = values.group_by{|i| i}.map{|k, v| [k.to_s, v.count]}.to_h

        @frequencies = old_freqs.merge(new_freqs){ |k, oldval, newval| oldval + newval }
      end

      set_store("frequencies", @frequencies)
      @frequencies
    end

    def sorted_values
      unless @sorted_values.present?
        previous_values = get_store("sorted_values", [])
        @sorted_values = (previous_values + values).sort
      end

      set_store("sorted_values", @sorted_values)
      @sorted_values
    end

    def get_store(key, default_val)
      @old_store.fetch(key, default_val) || default_val
    end

    def set_store(key, value)
      @new_store[key] = value
      value
    end

    def values
      @values ||= relevant_extracts.map do |extract|
        if extract.data[field_name].present?
          extract.data[field_name].to_f
        else
          nil
        end
      end.select{ |value| not value.nil? }
      @values
    end

    def relevant_extracts
      return extracts if extractor_name.blank?
      return extracts.select { |extract| extract.extractor_key == extractor_name }
    end

    def summarize_field
      config['summarize_field']
    end

    def operations
      if config['operations'].is_a? Array
        config['operations'].uniq
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
