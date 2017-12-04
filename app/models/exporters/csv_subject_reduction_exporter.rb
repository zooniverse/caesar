module Exporters
  class CsvSubjectReductionExporter < CsvExporter
    def get_topic
      SubjectReduction
    end
  end
end
