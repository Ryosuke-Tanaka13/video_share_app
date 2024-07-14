# spec/factories/questionnaire_items.rb
FactoryBot.define do
  factory :questionnaire_item do
    association :video
    pre_question_text { "事前の質問テキスト" }
    post_question_text { "事後の質問テキスト" }
    required { false }

    trait :required do
      required { true }
    end
  end
end
