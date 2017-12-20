FactoryGirl.define do
  sequence(:classification_id) { |n| n }

  factory :extract do
    workflow
    subject

    classification_id { generate :classification_id }
    classification_at Time.zone.now

    extractor_key "foo"
  end
end
