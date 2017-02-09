require 'CSV'

class UnknownExporter < StandardError; end

class CsvExporter
  def initialize(mode)
    case mode
    when :extracts
      @mode = mode
    when :reductions
      @mode = mode
    else
      raise UnknownExporter, "Unknown type #{@mode}"
    end
  end

  def dump(workflow_id)
    path = case @mode
    when :extracts
      "tmp/extracts_#{workflow_id}.csv"
    when :reductions
      "tmp/reductions_#{workflow_id}.csv"
    end

    items = case @mode
    when :extracts
      Extract.where(workflow_id: workflow_id)
    when :reductions
      Reduction.where(workflow_id: workflow_id)
    end

    model_cols = get_model_cols
    json_cols = get_unique_json_cols(workflow_id)

    CSV.open(path, "wb",
      :write_headers => true,
      :headers => get_csv_headers(workflow_id)
    ) do |csv|
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

  def get_model_cols
    case @mode
    when :extracts
      Extract.attribute_names - ["data"]
    when :reductions
      Reduction.attribute_names - ["data"]
    end
  end

  def get_unique_json_cols(workflow_id)
    case @mode
    when :extracts
      Extract
        .where(workflow_id: workflow_id)
        .select("DISTINCT(jsonb_object_keys(data)) AS key")
        .map(&:attributes)
        .map{|k| k["key"]}
    when :reductions
      Reduction
        .where(workflow_id: workflow_id)
        .select("DISTINCT(jsonb_object_keys(data)) AS key")
        .map(&:attributes)
        .map{|k| k["key"]}
    end
  end

end
