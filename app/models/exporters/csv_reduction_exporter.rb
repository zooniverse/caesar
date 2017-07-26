module Exporters
  class CsvReductionExporter < CsvExporter
    def get_topic
      Reduction
    end
  end
end
