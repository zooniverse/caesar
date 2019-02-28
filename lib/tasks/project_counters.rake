desc 'Update counter caches for projects'

namespace :counters do
  namespace :update do
    task projects: :environment do
      Project.reset_column_information
      Project.pluck(:id).each do |id|
        Project.reset_counters id, :subject_reductions, :user_reductions, :reducers
      end
    end
  end
end