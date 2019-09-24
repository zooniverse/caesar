class ExtractWorkerExternal < ExtractWorker
  sidekiq_options queue: 'external'
end