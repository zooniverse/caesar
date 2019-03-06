FactoryBot.define do
  factory :subject_reduction do
    reducible { create :workflow }
    subject

    reducer_key { "foo" }
  end
end
