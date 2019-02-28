desc 'Update counter caches for workflows'
namespace :counters do
  namespace :update do
    task workflows: :environment do
      Workflow.reset_column_information
      Workflow.pluck(:id).each do |id|
        Workflow.reset_counters id, :extracts, :subject_reductions, :user_reductions, :subject_actions, :user_actions, :extractors, :reducers, :subject_rules, :user_rules
      end
    end
  end
end