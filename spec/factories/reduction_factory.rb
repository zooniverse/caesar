FactoryGirl.define do
  factory :reduction do
    workflow
    subject

    reducer_key "foo"
  end
end
