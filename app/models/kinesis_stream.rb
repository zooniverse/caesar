class KinesisStream
  attr_reader :payload

  def receive(payload)
    ActiveRecord::Base.transaction do
      payload \
        .lazy
        .map    { |event| StreamEvents.from(event) }
        .select { |event| event.enabled? }
        .each   { |event| event.process }
    end
  end
end
