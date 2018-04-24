class ExtractFetcher
  attr_accessor :reduction_mode, :topic, :extract_ids, :strategy
  attr_reader :keys

  @@strategies = [ :fetch_all, :fetch_minimal ]
  def self.strategies
    @@strategies
  end

  def initialize(keys)
    @keys = keys

    @extract_ids = []
    @topic = :reduce_by_subject
    @strategy = :fetch_all
  end

  def strategy!(strategy)
    @strategy = strategy.to_sym
    @user_extracts = nil
    @subject_extracts = nil
    @exact_extracts = nil
  end

  def for(topic)
    ExtractFetcher.new(keys).tap do |fetcher|
      fetcher.topic = topic.to_sym
      fetcher.extract_ids = @extract_ids
      fetcher.strategy = @strategy
    end
  end

  def including(extract_ids)
    ExtractFetcher.new(keys).tap do |fetcher|
      fetcher.extract_ids = (@extract_ids + extract_ids).uniq
      fetcher.topic = @topic
      fetcher.strategy = @strategy
    end
  end

  def extracts
    if fetch_minimal?
      exact_extracts
    elsif fetch_subjects?
      subject_extracts
    elsif fetch_users?
      user_extracts
    end
  end

  def fetch_minimal?
    @strategy == :fetch_minimal
  end

  def fetch_users?
    @topic == :reduce_by_user
  end

  def fetch_subjects?
    @topic == :reduce_by_subject
  end

  def user_extracts
    @user_extracts ||= Extract.where(keys.except(:subject_id)).order(classification_at: :desc)
  end

  def subject_extracts
    @subject_extracts ||= Extract.where(keys.except(:user_id)).order(classification_at: :desc)
  end

  def exact_extracts
    @exact_extracts ||= Extract.find(@extract_ids).sort_by{ |e| e.classification_at }
  end
end
