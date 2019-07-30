namespace :data_repair do
  task nfn: :environment do
    query = %q(
      select user_id, reducer_key, subgroup
      from user_reductions
      where reducible_type='Project' and reducible_id=1558
      group by reducible_type, reducible_id, reducer_key, user_id, subgroup
      having count(*) > 1
    )

    affected_items = ActiveRecord::Base.connection.execute(query)

    affected_items.each do |params|
      user_id,  reducer_key, subgroup = params

      ActiveRecord::Base.transaction do
        reductions = UserReduction.where(
          reducible_type: 'Project',
          reducible_id: 1558,
          user_id: user_id,
          reducer_key: reducer_key,
          subgroup: subgroup
        ).lock(true)

        data = {
          extracts: reductions.inject(0){ |sum, r| sum + r.data['extracts'] },
          classifications: reductions.inject(0){ |sum, r| sum + r.data['classifications'] },
        }

        new_reduction = UserReduction.create!(
          reducible_type: 'Project',
          reducible_id: 1558,
          reducer_key: reducer_key,
          user_id: user_id,
          subgroup: subgroup,
          data: data
        )

        reductions.each do |reduction|
          reduction.extracts do |extract|
            new_reduction.extracts << extract
          end
        end

        new_reduction.save!

        reductions.delete_all
      end
    end
  end
end
