class CountingHash
  def self.build
    results = new
    yield results
    results.to_h
  end

  def initialize
    @value = {}
  end

  def increment(key, amount = 1)
    @value[key] ||= 0
    @value[key] += amount
  end

  def to_h
    @value
  end
end
