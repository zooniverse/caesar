# frozen_string_literal: true

namespace :extracts do
  desc 'Backfill mark_remove column default in batches'
  task backfill_machine_data_extracts: :environment do
    Extract.where(machine_data: nil).select(:id).find_in_batches do |extracts|
      extract_ids_to_update = extracts.map(&:id)
      Extract.where(id: extract_ids_to_update).update_all(machine_data: false)
    end
  end
end
