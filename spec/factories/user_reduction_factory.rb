FactoryGirl.define do
  factory :user_reduction do
    workflow
    user_id 1234

    reducer_key "foo"
  end
end
