namespace :export do
  namespace :csv do
    task :extracts, [:workflow_id] => [:environment] do |t, args|
      Exporters::CsvExtractExporter.new.dump(args[:workflow_id])
    end
    task :reductions, [:workflow_id] => [:environment] do |t, args|
      Exporters::CsvReductionExporter.new.dump(args[:workflow_id])
    end
  end
end
