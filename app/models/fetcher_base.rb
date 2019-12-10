class FetcherBase
  STRATEGIES = [ :fetch_all, :fetch_minimal ]

  def self.for(reducers)
    strategy = reducers.all?(&:running_reduction?) ? :fetch_minimal : :fetch_all
    new(strategy)
  end

  def initialize(strategy = :fetch_all)
    raise ArgumentError, "Unknown strategy" unless STRATEGIES.include?(strategy)
    @strategy = strategy
  end
end
