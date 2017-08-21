FactoryGirl.define do
  factory :data_request do
    workflow
    requested_data :extracts
  end
end
