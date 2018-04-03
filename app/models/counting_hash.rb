class CountingHash
  def self.build(initial_values = {})
    results = new(initial_values)
    yield results
    results.to_h
  end

  def initialize(val = {})
    @value = val
  end

  def increment(key, amount = 1)
    @value[key] ||= 0
    @value[key] += amount
  end

  def max
    return [nil, 0] if @value.blank?

    @value.reduce do |elm, acc|
      elm[1] > acc[1] ? elm : acc
    end
  end

  def sum
    @value.values.sum
  end

  def to_h
    @value
  end
end
