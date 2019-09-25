class DeferredQueue
  def initialize
    @jobs = []
  end

  def commit
    @jobs.each do |worker, custom_queue_name, args|
      if custom_queue_name
        worker.set(queue: custom_queue_name)
              .perform_async(*args)
      else
        worker.perform_async(*args)
      end
    end
  end

  def add(worker, custom_queue_name, *args)
    @jobs << [worker, custom_queue_name, args]
  end
end
