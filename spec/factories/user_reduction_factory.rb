FactoryBot.define do
  factory :user_reduction do
    reducible { create :workflow }
    user_id { 1234 }

    reducer_key { "foo" }
  end
end
