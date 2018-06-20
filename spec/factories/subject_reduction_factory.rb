FactoryGirl.define do
  factory :subject_reduction do
    reducible { build :workflow }
    subject

    reducer_key "foo"
  end
end
