class ApplicationStatus
  def sidekiq_queue_size
    Sidekiq::Queue.new.size
  end

  def classification_queue_size
    Classification.count
  end

  def newest_extract_date
    Extract.order(id: :desc).first&.created_at
  end

  def newest_subject_reduction_date
    SubjectReduction.order(id: :desc).first&.created_at
  end

  def newest_action_date
    [SubjectAction.order(id: :desc).first&.created_at].concat(
    [UserAction.order(id: :desc).first&.created_at ]).reject{|e| e.blank?}.min
  end

  def commit_id
    path = Rails.root.join("commit_id.txt")
    if File.exist? path
      File.read(path)
    else
      'your commit id here'
    end
  end

  def as_json(options = {})
    {
      sidekiq_queue_size: sidekiq_queue_size,
      classification_queue_size: classification_queue_size,
      newest_extract_date: newest_extract_date,
      newest_reduction_date: newest_reduction_date,
      newest_action_date: newest_action_date,
      commit_id: commit_id
    }
  end
end
