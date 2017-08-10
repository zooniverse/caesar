FactoryGirl.define do
  factory :credential do
    transient do
      login "tester"
      admin false
      workflows { [] }
    end

    token "fake"
    expires_at 1.day.from_now
    project_ids { workflows.map(&:project_id).uniq }

    after(:build) do |credential, evaluator|
      credential.instance_variable_set(:@jwt_payload, {"login" => evaluator.login, "admin" => evaluator.admin})
    end

    trait :not_logged_in do
      login nil
    end

    trait :expired do
      expires_at { 5.minutes.ago }
    end

    trait :admin do
      admin true
    end
  end
end
