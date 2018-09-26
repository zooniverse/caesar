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
  end
end
