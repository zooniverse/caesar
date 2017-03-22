class RuleBindings
  class OverlappingKeys < StandardError; end

  def initialize(reductions)
    @reductions = reductions.index_by(&:reducer_id)
  end

  def fetch(key, defaultVal=nil)
    reducer_id, data_key = key.split(".")
    @reductions.fetch(reducer_id).data.fetch(data_key, defaultVal)
  end

  def keys
    @bindings.keys
  end

  def self.merge(results)
    results.reduce({}) do |memo, obj|
      raise OverlappingKeys, "left: #{memo.keys.inspect}, right: #{obj.keys.inspect}" if overlap?(memo, obj)
      memo.merge(obj)
    end
  end

  def self.overlap?(a, b)
    (a.keys & b.keys != [])
  end
end
