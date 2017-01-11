module MergesResults
  class OverlappingKeys < StandardError; end

  def self.merge(results)
    results.reduce({}) do |memo, obj|
      raise OverlappingKeys if overlap?(memo, obj)
      memo.merge(obj)
    end
  end

  def self.overlap?(a, b)
    (a.keys & b.keys != [])
  end
end
