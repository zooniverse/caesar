FactoryGirl.define do
  factory :reduction do
    workflow
    subject

    reducer_id "foo"
  end
end
