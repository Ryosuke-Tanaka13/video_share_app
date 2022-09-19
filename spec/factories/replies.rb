FactoryBot.define do
  factory :user_reply, class: 'Reply' do
    association :user
    association :organization
    association :comment
    reply { 'userの返信' }
  end


  factory :viewer_reply, class: 'Reply' do
    association :viewer
    association :organization
    association :comment
    reply { 'viewerの返信' }
  end

end

