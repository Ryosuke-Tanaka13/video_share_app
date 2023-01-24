FactoryBot.define do
  factory :system_admin_reply, class: 'Reply' do
    organization_id { 1 }
    comment_id { 1 }
    reply { 'system_adminの返信' }
  end

  factory :user_reply, class: 'Reply' do
    organization_id { 1 }
    comment_id { 1 }
    reply { 'userの返信' }
  end

  factory :another_user_reply, class: 'Reply' do
    organization_id { 1 }
    comment_id { 1 }
    reply { 'another_userの返信' }
  end

  factory :viewer_reply, class: 'Reply' do
    organization_id { 1 }
    comment_id { 1 }
    reply { 'viewerの返信' }
  end
end
