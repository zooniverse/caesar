FactoryGirl.define do
  factory :data_request do
    exportable { create :workflow }
    workflow_id { exportable.id }
    requested_data :extracts
  end
end
