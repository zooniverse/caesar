require 'csv'

module Exporters
  class UnknownExporter < StandardError; end

  class CsvExporter
    attr_reader :workflow_id, :user_id, :subgroup

    def initialize(params)
      @workflow_id = params[:workflow_id]
      @user_id = params[:user_id]
      @subgroup = params[:subgroup]
    end

    def dump(path=nil)
      if path.blank?
        path = "tmp/#{get_topic.name.demodulize.underscore.pluralize}_#{workflow_id}.csv"
      end

      items = get_items
      total = items.count
      progress = 0

      CSV.open(path, "wb",
        :write_headers => true,
        :headers => get_csv_headers) do |csv|
        items.find_each do |item|
          csv << extract_row(item)
          progress += 1
          yield(progress, total) if block_given?
        end
      end
    end

    def get_csv_headers
      get_model_cols + get_unique_json_cols.map{|col| "data.#{col}"}
    end

    def extract_row(source_row)
      model_cols = get_model_cols
      json_cols = get_unique_json_cols

      string_source = source_row.attributes.stringify_keys
      model_values = model_cols.map{ |col| format_item(string_source[col]) }
      json_values = json_cols.map{ |col| format_item(source_row[:data][col]) }
      model_values + json_values
    end

    private

    def format_item(item)
      return "" unless item.present?

      case item
        when Integer, Float, String, TrueClass, FalseClass then item
        when Array then item.to_json
        when Hash then item.to_json
        when DateTime, ActiveSupport::TimeWithZone then item
      end
    end

    def get_items
      find_hash = { :workflow_id => workflow_id }
      find_hash[:user_id] = user_id unless user_id.blank?
      find_hash[:subgroup] = subgroup unless subgroup.blank?
      get_topic.where(find_hash)
    end

    def get_model_cols
      @model_cols ||= get_topic.attribute_names - ["data", "store"]
    end

    def get_unique_json_cols
      @unique_json_cols ||= get_items
                              .select("DISTINCT(jsonb_object_keys(data)) AS key")
                              .map(&:key)
    end

  end
end
