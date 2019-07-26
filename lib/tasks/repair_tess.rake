namespace :data_repair do
  task :tess do
    query = %q(
      select user_id
      from user_reductions
      where reducible_type='Workflow' and reducible_id=11235
      group by reducible_type, reducible_id, reducer_key, user_id, subgroup
      having count(*) > 1
    )

    affected_items = ActiveRecord::Base::Connection.execute(query)
    affected_items.each do |user_id|
      ActiveRecord::Base.transaction do
        UserReductions.where(
          reducible_type: 'Workflow',
          reducible_id: 11235,
          user_id: user_id,
        ).delete_all

        FetchClassificationsWorker.perform_async(11235, user_id, FetchClassificationsWorker.fetch_for_user)
      end
    end
  end
end
