module MergesResults
  class OverlappingKeys < StandardError; end

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
