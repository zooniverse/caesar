class ReduceWorkerExternal < ReduceWorker
  sidekiq_options queue: 'external'
end