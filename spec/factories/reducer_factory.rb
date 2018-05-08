FactoryGirl.define do
  sequence :key do |n|
    "key#{n}"
  end

  factory :reducer do
    reducible nil
    key { generate(:key) }
    config { {} }

    factory :stats_reducer, class: Reducers::StatsReducer
    factory :external_reducer, class: Reducers::ExternalReducer
  end
end
