require 'csv'

module Exporters
  class UnknownExporter < StandardError; end

  class CsvExporter
    attr_reader :resource_id, :resource_type, :user_id, :subgroup, :requested_data

    def initialize(params)
      @resource_id = params[:resource_id]
      @resource_type = params[:resource_type]
      @user_id = params[:user_id]
      @subgroup = params[:subgroup]
      @requested_data = params[:requested_data]
    end

    def dump(path=nil, estimated_count: nil)
      if path.blank?
        path = "tmp/#{export_resource_class.name.demodulize.underscore.pluralize}_#{resource_id}.csv"
      end

      total = estimated_count || 0
      progress = 0

      CSV.open(path, 'wb', write_headers: true, headers: csv_headers) do |csv|
        exportable_scope.find_each do |item|
          csv << extract_row(item)
          progress += 1
          yield(progress, total) if block_given?

          # let someone else use the CPU for a bit to try to appease docker
          # https://stackoverflow.com/questions/36753094/sleep-0-has-special-meaning
          sleep(0) unless progress % 1000
        end
      end
    end

    def csv_headers
      model_cols + unique_json_cols_keys.map { |col| "data.#{col}" }
    end

    def extract_row(source_row)
      string_source = source_row.attributes.stringify_keys
      model_values = model_cols.map { |col| format_item(string_source[col]) }
      json_values = unique_json_cols_keys.map { |col| format_item(source_row[:data][col]) }
      model_values + json_values
    end

    private

    def format_item(item)
      return '' unless item.present?

      case item
      when Integer, Float, String, TrueClass, FalseClass,DateTime, ActiveSupport::TimeWithZone
        item
      when Array, Hash
        item.to_json
      end
    end

    def export_resource_class
      requested_data.camelcase.singularize.constantize
    end

    def exportable_scope
      # this is an  an optimization fence using a CTE
      # to force the query planner to use the indexed columns on the exportable resouce table (workflow_id, reducible_id, reducible_type etc)
      # so we can resolve the export query scopes in a decent timeframe
      # and avoid the table scans with filtering that the query planner currently uses
      # due to a lack of selectivity on the exportable resource table indexes (i.e. PK scan over the table and filter on the where clauses)
      export_resource_class.with(export_resource_class.table_name => export_resource_class.where(exportable_scope_where_clause))
    end

    def exportable_scope_where_clause
      find_hash = case export_resource_class.to_s
                  when 'Extract'
                    { workflow_id: resource_id }
                  when 'SubjectReduction', 'UserReduction'
                    { reducible_id: resource_id, reducible_type: resource_type }
                  end
      find_hash[:user_id] = user_id if user_id.present? && export_resource_class != SubjectReduction
      find_hash[:subgroup] = subgroup if subgroup.present?
      find_hash
    end

    def model_cols
      @model_cols ||= export_resource_class.attribute_names - %w[data store]
    end

    def unique_json_cols_keys
      @unique_json_cols_keys ||= unique_json_cols_scope.map(&:key)
    end

    def unique_json_cols_scope
      export_resource_class.with(
        export_resource_class.table_name =>
          export_resource_class
            .where(exportable_scope_where_clause)
            .where("jsonb_typeof(#{export_resource_class.table_name}.data)='object'")
            .select("DISTINCT(jsonb_object_keys(#{export_resource_class.table_name}.data)) AS key")
      ).select(:key)
    end
  end
end
