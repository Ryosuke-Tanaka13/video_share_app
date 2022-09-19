FactoryBot.define do
  factory :user_comment, class: 'Comment' do
    association :user
    association :organization
    association :video
    comment { 'userのコメント' }
  end


  factory :viewer_comment, class: 'Comment' do
    association :viewer
    association :organization
    association :video
    comment { 'viewerのコメント' }
  end

  factory :comment, class: 'Comment' do
    association :organization
    association :video
    comment { 'テストコメント' }
  end

end
