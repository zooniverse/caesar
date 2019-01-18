FactoryGirl.define do
  sequence :key do |n|
    "key#{n}"
  end

  factory :reducer do
    reducible { create :workflow }
    key { generate(:key) }
    config { {} }

    factory :placeholder_reducer, class: Reducers::PlaceholderReducer
    factory :stats_reducer, class: Reducers::StatsReducer
    factory :external_reducer, class: Reducers::ExternalReducer

    trait :reduce_by_subject do
      topic 'reduce_by_subject'
    end

    trait :reduce_by_user do
      topic 'reduce_by_user'
    end
  end
end
