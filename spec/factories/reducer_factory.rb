FactoryGirl.define do
  factory :reducer do
    configurable nil
    key "MyString"
    config { {} }

    factory :stats_reducer, class: Reducers::StatsReducer
    factory :external_reducer, class: Reducers::ExternalReducer
  end
end
