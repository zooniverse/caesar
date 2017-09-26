FactoryGirl.define do
  factory :reducer do
    workflow nil
    key "MyString"
    config { {} }

    factory :stats_reducer, class: Reducers::StatsReducer
    factory :external_reducer, class: Reducers::ExternalReducer
  end
end
