class ExtractFetcher
  attr_accessor :reduction_mode, :topic, :extract_ids, :strategy
  attr_reader :selector

  def initialize(selector)
    @selector = selector
    @extract_ids = []
    @topic = :reduce_by_subject
    @strategy = :fetch_all
  end

  def strategy(strategy)
    @strategy = strategy.to_sym
  end

  def for(topic)
    @topic = topic.to_sym
    self
  end

  def including(extract_ids)
    @extract_ids = (@extract_ids + extract_ids).uniq
    self
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

  def fetch_users?
    @topic == :reduce_by_user
  end

  def fetch_subjects?
    @topic == :reduce_by_subject
  end

  def user_extracts
    @user_extracts ||= Extract.where(selector.except(:subject_id)).order(classification_at: :desc)
  end

  def subject_extracts
    @subject_extracts ||= Extract.where(selector.except(:user_id)).order(classification_at: :desc)
  end

  def specified_extracts
    @specified_extracts ||= Extract.find(@extract_ids).sort_by{ |e| e.classification_at }
  end
end
