class FetcherBase
  STRATEGIES = [ :fetch_all, :fetch_minimal ]

  def initialize(strategy: nil, reducers: [])
    if strategy
      raise ArgumentError, "Unknown strategy" unless STRATEGIES.include?(strategy)
      @strategy = strategy
    else
      @strategy = detect_best_strategy(reducers)
    end
  end

  private

  def detect_best_strategy(reducers)
    if reducers.present? && reducers.all?(&:running_reduction?) 
      :fetch_minimal
    else
      :fetch_all
    end
  end
end
