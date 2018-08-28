namespace :export do
  namespace :csv do
    task :extracts, [:resource_id, :resource_type] => [:environment] do |t, args|
      Exporters::CsvExtractExporter.new(resource_id: args[:resource_id], resource_type: args[:resource_type]).dump
    end
    task :reductions, [:resource_id, :resource_type] => [:environment] do |t, args|
      Exporters::CsvSubjectReductionExporter.new(resource_id: args[:resource_id], resouce_type: args[:resource_type]).dump
    end
  end
end
