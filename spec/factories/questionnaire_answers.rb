FactoryBot.define do
  factory :questionnaire_answer do
    association :questionnaire_item
    association :viewer
    association :video
    viewer_name { 'テストユーザー' }
    viewer_email { 'test@example.com' }
    pre_answers { { questionnaire_item.id.to_s => '有効な回答' } }
    post_answers { { questionnaire_item.id.to_s => '有効な回答' } }
  end
end
