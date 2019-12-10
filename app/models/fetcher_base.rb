class FetcherBase
  STRATEGIES = [ :fetch_all, :fetch_minimal ]

  def initialize(strategy = :fetch_all)
    raise ArgumentError, "Unknown strategy" unless STRATEGIES.include?(strategy)
    @strategy = strategy
  end
end
