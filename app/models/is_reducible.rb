module IsReducible
  extend ActiveSupport::Concern

  def concerns_subjects?
    subject_rules.present? or reducers.where(topic: 'reduce_by_subject').present?
  end

  def concerns_users?
    user_rules.present? or reducers.where(topic: 'reduce_by_user').present?
  end

  def rerun_reducers(duration = 3.hours)
    if concerns_subjects?
      extracts.group_by(&:subject_id).each do |subject_id, extracts|
        ReduceWorker.perform_in(rand(duration.to_i).seconds, id, self.class.name, subject_id, nil, extracts.pluck(:id))
      end
    end

    if concerns_users?
      extracts.group_by(&:user_id).except(nil).each do |user_id, extracts|
        ReduceWorker.perform_in(rand(duration.to_i).seconds, id, self.class.name, nil, user_id, extracts.pluck(:id))
      end
    end
  end
end
