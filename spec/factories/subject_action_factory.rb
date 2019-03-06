FactoryBot.define do
  factory :subject_action do
    workflow
    subject

    effect_type { "retire_subject" }
    status { "completed" }
  end
end
