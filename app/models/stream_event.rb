module StreamEvent
  module IgnoredEvent
    def self.enabled?
      false
    end
  end

  class ClassificationEvent
    def initialize(hash)
      @data = hash.fetch("data")

      @linked = {}
      hash.fetch("linked").each do |link_type, linked_records| 
        @linked[link_type] = linked_records.reduce(Hash.new) do |memo, obj|
          memo[obj.fetch("id")] = obj
          memo
        end
      end
    end

    def enabled?
      true
    end

    def classification
      Classification.new(@data)
    end

    def workflow
      id = @data.fetch("links").fetch("workflow")
      @linked.fetch("workflows").fetch(id)
    end

    def subjects
      @linked.fetch("subjects").values
    end
  end

  def self.from(hash)
    if hash.fetch("source") == "panoptes" && hash.fetch("type") == "classification"
      ClassificationEvent.new(hash)
    else
      IgnoredEvent
    end
  end
end
