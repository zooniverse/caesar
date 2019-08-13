class FetcherBase
  attr_reader :query, :topic

  def initialize(query)
    @query = query
    @topic = :fetch_by_subject
  end

  def for!(topic)
    @topic = if topic.to_sym == :reduce_by_subject
      :fetch_by_subject
    elsif topic.to_sym == :reduce_by_user
      :fetch_by_user
    else
      raise ArgumentError.new 'This topic is not supported'
    end

    self
  end

  def fetch_by_user?
    @topic == :fetch_by_user
  end

  def fetch_by_subject?
    @topic == :fetch_by_subject
  end
end