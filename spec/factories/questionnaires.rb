FactoryBot.define do
  factory :questionnaire do
    association :user
    pre_video_questionnaire { '[]' }
    post_video_questionnaire { '[]' }
  end
end
