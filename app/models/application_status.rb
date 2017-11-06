class ApplicationStatus
  def sidekiq_queue_size
    Sidekiq::Queue.new.size
  end

  def newest_extract_date
    Extract.order(id: :desc).first&.created_at
  end

  def newest_reduction_date
    Reduction.order(id: :desc).first&.created_at
  end

  def newest_action_date
    Action.order(id: :desc).first&.created_at
  end

  def as_json(options = {})
    {
      sidekiq_queue_size: sidekiq_queue_size,
      newest_extract_date: newest_extract_date,
      newest_reduction_date: newest_reduction_date,
      newest_action_date: newest_action_date
    }
  end
end
