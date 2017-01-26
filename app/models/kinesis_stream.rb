class KinesisStream
  attr_reader :payload

  def receive(payload)
    ActiveRecord::Base.transaction do
      payload.each { |event| StreamEvents.from(event).process }
    end
  end
end
