class ReduceWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_options unique: :until_and_while_executing, unique_args: :unique_args unless Rails.env.test?
  sidekiq_options queue: 'internal'
  sidekiq_retry_in do |count|
    (count ** 8) + 15 + (rand(30) * count + 1)
  end

  def self.unique_args(args)
    reducible_id, reducible_class, subject_id, user_id, extract_ids = args
    reducible = reducible_class.constantize.find(reducible_id)
    reducers = reducible.reducers

    uniques = [reducible_id, reducible_class]
    uniques.push subject_id if reducers.any? { |r| r.reduce_by_subject? }
    uniques.push user_id if reducers.any? { |r| r.reduce_by_user? }
    uniques.push extract_ids if reducers.any? { |r| r.running_reduction? }

    uniques
  end

  def perform(reducible_id, reducible_class, subject_id, user_id, extract_ids = [])
    reducible = reducible_class.constantize.find(reducible_id)
    return if reducible.class.name.demodulize=='Workflow' && reducible.paused?
    reductions = reducible.classification_pipeline.reduce(reducible_id, subject_id, user_id, extract_ids)
    CheckRulesWorker.perform_async(reducible_id, reducible_class, subject_id, user_id) unless reductions.blank?
  end

  def self.test_uniq(testing)
    if testing
      sidekiq_options unique: :until_and_while_executing, unique_args: :unique_args
    else
      sidekiq_options unique: :until_and_while_executing, unique_args: :unique_args unless Rails.env.test?
    end
  end
end
