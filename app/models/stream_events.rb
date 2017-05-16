module StreamEvents
  def self.from(stream, hash)
    if hash.fetch("source") == "panoptes" && hash.fetch("type") == "classification"
      StreamEvents::ClassificationEvent.new(stream, hash)
    else
      StreamEvents::UnknownEvent
    end
  end

  def self.linked_to_hash(linked)
    {}.tap do |result|
      linked.each do |link_type, linked_records|
        result[link_type] = linked_records.each_with_object(Hash.new) do |obj, memo|
          memo[obj.fetch("id")] = obj
        end
      end
    end
  end
end
