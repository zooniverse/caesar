require 'csv'

module Exporters
  class UnknownExporter < StandardError; end

  class CsvExporter
    def dump(workflow_id)
      path = get_path(workflow_id)
      items = get_items(workflow_id)

      model_cols = get_model_cols
      json_cols = get_unique_json_cols(workflow_id)

      CSV.open(path, "wb",
        :write_headers => true,
        :headers => get_csv_headers(workflow_id)) do |csv|

        items.each do |item|
          csv << extract_row(item, model_cols, json_cols)
        end

      end
    end

    def get_csv_headers(workflow_id)
      get_model_cols + get_unique_json_cols(workflow_id).map{|col| "data.#{col}"}
    end

    def extract_row(source_row, model_cols, json_cols)
      string_source = source_row.attributes.stringify_keys
      model_values = model_cols.map{|col| string_source[col] || ""}
      json_values = json_cols.map{|col| source_row[:data][col] || ""}
      model_values + json_values
    end
  end
end
