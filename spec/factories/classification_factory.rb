FactoryBot.define do
  factory :classification do
    id { generate :classification_id }
    project_id { workflow&.project_id || 1 }
    workflow_version { "1.1" }
  end
end
