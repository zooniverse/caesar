FactoryBot.define do
  factory :credential do
    transient do
      login { "tester" }
      admin { false }
      logged_in { true }
      user_id { -1 }
      workflows { [] }
      expired { false }
    end

    token { "fake" }
    project_ids { workflows.map(&:project_id).uniq }

    after(:build) do |credential, evaluator|
      credential.instance_variable_set(:@admin, evaluator.admin)
      credential.instance_variable_set(:@login, evaluator.login)
      credential.instance_variable_set(:@logged_in, evaluator.logged_in)
      credential.instance_variable_set(:@user_id, evaluator.user_id)
      credential.instance_variable_set(:@expired, evaluator.expired)
    end

    trait :not_logged_in do
      login { nil }
      logged_in { false }
    end

    trait :expired do
      expired { true }
    end

    trait :admin do
      admin { true }
    end
  end
end
