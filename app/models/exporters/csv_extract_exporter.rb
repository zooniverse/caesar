module Exporters
  class CsvExtractExporter < CsvExporter
    def get_path(workflow_id)
      "tmp/extracts_#{workflow_id}.csv"
    end

    def get_items(workflow_id)
      Extract.where(workflow_id: workflow_id)
    end

    def get_model_cols
      Extract.attribute_names - ["data"]
    end

    def get_unique_json_cols(workflow_id)
      Extract
        .where(workflow_id: workflow_id)
        .select("DISTINCT(jsonb_object_keys(data)) AS key")
        .map(&:key)
    end
  end
end
