module Exporters
  class CsvReductionExporter < CsvExporter
    def get_path(workflow_id)
      "tmp/reductions_#{workflow_id}.csv"
    end

    def get_items(workflow_id)
      Reduction.where(workflow_id: workflow_id)
    end

    def get_model_cols
      Reduction.attribute_names - ["data"]
    end

    def get_unique_json_cols(workflow_id)
      Reduction
        .where(workflow_id: workflow_id)
        .select("DISTINCT(jsonb_object_keys(data)) AS key")
        .map(&:key)
    end
  end
end
