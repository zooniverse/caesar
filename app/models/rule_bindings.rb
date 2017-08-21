class RuleBindings
  class OverlappingKeys < StandardError; end

  def initialize(reductions)
    @reductions = reductions.index_by(&:reducer_key)
  end

  def fetch(key, defaultVal=nil)
    reducer_key, data_key = key.split(".")
    return @reductions.fetch(reducer_key) if data_key.nil?
    @reductions.fetch(reducer_key).data.fetch(data_key, defaultVal)
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
