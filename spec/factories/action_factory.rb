FactoryGirl.define do
  factory :action do
    workflow
    subject

    effect_type "retire_subject"
    status "completed"
  end
end
