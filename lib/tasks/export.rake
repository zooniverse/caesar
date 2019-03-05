namespace :export do
  namespace :csv do
    task :extracts, [:resource_id, :resource_type] => [:environment] do |t, args|
      Exporters::CsvExporter.new(resource_id: args[:resource_id], resource_type: args[:resource_type], requested_data: 'extracts').dump
    end
    task :reductions, [:resource_id, :resource_type] => [:environment] do |t, args|
      Exporters::CsvExporter.new(resource_id: args[:resource_id], resouce_type: args[:resource_type], requested_data: 'subject_reductions').dump
    end
    task :subject_reductions, [:resource_id, :resource_type] => [:environment] do |t, args|
      Exporters::CsvExporter.new(resource_id: args[:resource_id], resouce_type: args[:resource_type], requested_data: 'subject_reductions').dump
    end
    task :user_reductions, [:resource_id, :resource_type] => [:environment] do |t, args|
      Exporters::CsvExporter.new(resource_id: args[:resource_id], resouce_type: args[:resource_type], requested_data: 'user_reductions').dump
    end
  end
end
