FactoryBot.define do
  factory :data_request do
    exportable { create :workflow }
    requested_data { :extracts }
  end
end
