FactoryGirl.define do
  factory :user_rule_effect do
    action :promote_user
    config { {workflow_id: 1} }
  end
end
