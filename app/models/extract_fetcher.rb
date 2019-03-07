class ExtractFetcher
  attr_accessor :reduction_mode, :topic, :extract_ids, :strategy
  attr_reader :filter

  @@strategies = [ :fetch_all, :fetch_minimal ]
  def self.strategies
    @@strategies
  end

  def initialize(filter, extract_ids: [], reducers:)
    @filter = filter
    @extract_ids = extract_ids.uniq
    @topic = :reduce_by_subject

    # if we don't need to fetch everything, try not to
    if reducers.all?{ |reducer| reducer.running_reduction? }
      @strategy = :fetch_minimal
    else
      @strategy = :fetch_all
    end
  end

  def strategy!(strategy)
    @strategy = strategy.to_sym
    @user_extracts = nil
    @subject_extracts = nil
    @specified_extracts = nil
  end

  def for(topic)
    ExtractFetcher.new(filter).tap do |fetcher|
      fetcher.topic = topic.to_sym
      fetcher.extract_ids = @extract_ids
      fetcher.strategy = @strategy
    end
  end

  def extracts
    if fetch_minimal?
      specified_extracts
    elsif fetch_subjects?
      subject_extracts | specified_extracts
    elsif fetch_users?
      user_extracts | specified_extracts
    end
  end

  def fetch_minimal?
    @strategy == :fetch_minimal
  end

  def fetch_additional?
    @strategy == :fetch_additional
  end

  def fetch_users?
    @topic == :reduce_by_user
  end

  def fetch_subjects?
    @topic == :reduce_by_subject
  end

  def user_extracts
    @user_extracts ||= Extract.where(filter.except(:subject_id)).order(classification_at: :desc)
  end

  def subject_extracts
    @subject_extracts ||= Extract.where(filter.except(:user_id)).order(classification_at: :desc)
  end

  def specified_extracts
    @specified_extracts ||= Extract.find(@extract_ids).sort_by{ |e| e.classification_at }
  end
end
