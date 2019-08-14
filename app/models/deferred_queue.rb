class DeferredQueue
  def initialize
    @jobs = []
  end

  def commit
    @jobs.each do |worker, args|
      worker.perform_async(*args)
    end
  end

  def add(worker, *args)
    @jobs << [worker, args]
  end
end
