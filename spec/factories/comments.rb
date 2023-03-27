FactoryBot.define do
  factory :system_admin_comment, class: 'Comment' do
    comment { 'system_adminのコメント' }
    organization_id { 1 }
    video_id { 1 }
  end

  factory :user_comment, class: 'Comment' do
    comment { 'userのコメント' }
    organization_id { 1 }
    video_id { 1 }
  end

  factory :another_user_comment, class: 'Comment' do
    comment { 'another_userのコメント' }
    organization_id { 1 }
    video_id { 1 }
  end

  factory :viewer_comment, class: 'Comment' do
    comment { 'viewerのコメント' }
    organization_id { 1 }
    video_id { 1 }
  end

  factory :another_viewer_comment, class: 'Comment' do
    comment { 'another_viewerのコメント' }
    organization_id { 1 }
    video_id { 1 }
  end

  factory :comment, class: 'Comment' do
    association :organization
    association :video
    comment { 'テストコメント' }
  end
end
