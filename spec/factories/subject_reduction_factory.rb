FactoryGirl.define do
  factory :subject_reduction do
    workflow
    subject

    reducer_key "foo"
  end
end
