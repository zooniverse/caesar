namespace :export do
  namespace :csv do
    task :extracts, [:workflow_id] => [:environment] do | t, args |
      CsvExporter.new(:extracts).dump(args[:workflow_id])
    end
    task :reductions, [:workflow_id] => [:environment] do | t, args |
      CsvExporter.new(:reductions).dump(args[:workflow_id])
    end
  end
end
