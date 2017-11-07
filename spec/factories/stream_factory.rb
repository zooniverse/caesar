FactoryGirl.define do
  factory :classification_event, class: Hash do
    transient do
      workflow
      subject
    end

    id { generate :classification_id }
    created_at { Time.zone.now.iso8601 }
    updated_at { Time.zone.now.iso8601 }
    workflow_version { "1.1" }
    annotations { {} }
    metadata { {} }
    links {
      {
        "project" => workflow.project_id.to_s,
        "workflow" => workflow.id.to_s,
        "subjects" => [subject.id.to_s]
      }
    }

    initialize_with { attributes.stringify_keys }
  end
end
