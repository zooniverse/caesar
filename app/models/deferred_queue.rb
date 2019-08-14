class DeferredQueue
  def initialize
    @jobs = []
  end

  def commit
    @jobs.each do |worker, custom_queue_name, args|
      worker.set(queue: custom_queue_name.to_sym) if custom_queue_name.present?
      worker.perform_async(*args)
    end
  end

  def add(worker, custom_queue_name, *args)
    @jobs << [worker, custom_queue_name, args]
  end
end
