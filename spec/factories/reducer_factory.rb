FactoryGirl.define do
  factory :reducer do
    workflow nil
    key "MyString"
    type ""
    config ""

  end

  factory :stats_reducer, class: Reducers::StatsReducer do
  end

  factory :external_reducer, class: Reducers::ExternalReducer do
  end
end
