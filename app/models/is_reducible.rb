module IsReducible
  extend ActiveSupport::Concern

  def active?
    raise NotImplementedError.new 'Reducible resources must implement this method'
  end

  def paused?
    raise NotImplementedError.new 'Reducible resources must implement this method'
  end

  def halted?
    raise NotImplementedError.new 'Reducible resources must implement this method'
  end

  def concerns_subjects?
    reducers.where(topic: 'reduce_by_subject').present?
  end

  def concerns_users?
    reducers.where(topic: 'reduce_by_user').present?
  end

  def reducers_runner
    RunsReducers.new(self, reducers)
  end

  def rules_runner
    RunsRules.new(self, subject_rules.rank(:row_order), user_rules.rank(:row_order), rules_applied)
  end

  def rerun_reducers
    if concerns_subjects?
      subject_groups = extracts.pluck(:subject_id, :id).group_by{ |pair| pair[0] }

      # allow up to 90 subjects to be re-reduced per minute
      duration = (subject_groups.count / 90).ceil.minutes

      subject_groups.each do |subject_id, pairs|
        ReduceWorker.perform_in(rand(duration.to_i).seconds, id, self.class.name, subject_id, nil, pairs.map{ |pair| pair[1] })
      end
    end

    if concerns_users?
      user_groups = extracts.pluck(:user_id, :id).group_by{ |pair| pair[0] }

      # allow up to 10 users to be re-reduced per minute
      duration = (user_groups.count / 10).ceil.minutes

      user_groups.except(nil).each do |user_id, pairs|
        ReduceWorker.perform_in(rand(duration.to_i).seconds, id, self.class.name, nil, user_id, pairs.map{ |pair| pair[1] })
      end
    end
  end
end
