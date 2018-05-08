FactoryGirl.define do
  factory :data_request do
    reducible { build :workflow }
    requested_data :extracts
  end
end
