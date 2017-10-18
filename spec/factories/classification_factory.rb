FactoryGirl.define do
  factory :classification do
    id { generate :classification_id }
    project_id { workflow.project_id }
    workflow_version "1.1"
  end
end
