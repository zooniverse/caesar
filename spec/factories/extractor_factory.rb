FactoryGirl.define do
  factory :extractor do
    workflow nil
    key "MyString"
    config { {} }
    minimum_workflow_version nil
  end

  factory :survey_extractor, class: Extractors::SurveyExtractor do
  end

  factory :external_extractor, class: Extractors::ExternalExtractor do
  end
end
