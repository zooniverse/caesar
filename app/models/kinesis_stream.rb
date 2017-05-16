class KinesisStream
  attr_reader :queue

  def initialize
    @queue = DeferredQueue.new
  end

  def receive(payload)
    ActiveRecord::Base.transaction do
      payload.each { |event| StreamEvents.from(self, event).process }
    end

    queue.commit
  end
end
