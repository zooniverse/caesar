namespace :export do
  namespace :csv do
    task :extracts, [:workflow_id] => [:environment] do |t, args|
      Exporters::CsvExtractExporter.new(workflow_id: args[:workflow_id]).dump
    end
    task :reductions, [:workflow_id] => [:environment] do |t, args|
      Exporters::CsvReductionExporter.new(workflow_id: args[:workflow_id]).dump
    end
  end
end
