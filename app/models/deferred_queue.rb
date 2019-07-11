class DeferredQueue
  def initialize
    @jobs = []
  end

  def commit
    @jobs.each do |job|
      Sidekiq::Client.push(job)
    end
  end

  def add(job)
    @jobs << job
  end
end
