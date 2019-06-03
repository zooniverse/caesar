class DeferredQueue
  def initialize
    @jobs = []
  end

  def commit
    @jobs.each do |worker, args|
      delay = rand(5).seconds
      args.unshift(delay)
      worker.perform_in(*args)
    end
  end

  def add(worker, *args)
    @jobs << [worker, args]
  end
end
