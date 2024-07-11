FactoryBot.define do
  factory :questionnaire_answer do
    questionnaire { nil }
    viewer { nil }
    video { nil }
    answer { 'MyText' }
  end
end
