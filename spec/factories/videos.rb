FactoryBot.define do
  # 組織セレブエンジニアのオーナーが投稿したビデオ
  factory :video_sample, class: 'Video' do
    title { 'サンプルビデオ' }
    # 公開期間を現在時刻+2分に設定。(←+1分にするとテストに落ちる。requestsテストでは+1分でも通る。)
    open_period { Time.now + 2 }
    expire_type { 0 }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 1 }
    organization
    user

    # afterメソッド。Videoインスタンスをbuildした後、動画をつける。
    after(:build) do |video_sample|
      video_sample.video.attach(io: File.open('spec/fixtures/files/flower.mp4'), filename: 'flower.mp4', content_type: 'video/mp4')
    end
  end

  # 組織セレブエンジニアのスタッフが投稿したビデオ
  factory :video_test, class: 'Video' do
    title { 'テストビデオ' }
    open_period { Time.now + 5 }
    expire_type { 0 }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 3 }
    organization
    user

    # afterメソッド。Videoインスタンスをbuildした後、動画をつける。
    after(:build) do |video_test|
      video_test.video.attach(io: File.open('spec/fixtures/files/flower.mp4'), filename: 'flower.mp4', content_type: 'video/mp4')
    end
  end

  # 組織セレブエンジニアのオーナーが投稿したビデオ(視聴にはログイン必須)
  factory :video_login_must, class: 'Video' do
    title { 'ログイン必須ビデオ' }
    open_period { nil }
    expire_type { 0 }
    range { false }
    comment_public { false }
    login_set { true }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 1 }
    organization
    user

    # afterメソッド。Videoインスタンスをbuildした後、動画をつける。
    after(:build) do |video_login_must|
      video_login_must.video.attach(io: File.open('spec/fixtures/files/flower.mp4'), filename: 'flower.mp4', content_type: 'video/mp4')
    end
  end

  # 組織セレブエンジニアのオーナーが投稿したビデオ(論理削除されたもの)
  factory :video_deleted, class: 'Video' do
    title { 'デリートビデオ' }
    open_period { nil }
    expire_type { 0 }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { false }
    is_valid { false }
    organization_id { 1 }
    user_id { 1 }
    organization
    user

    # afterメソッド。Videoインスタンスをbuildした後、動画をつける。
    after(:build) do |video_delete|
      video_delete.video.attach(io: File.open('spec/fixtures/files/flower.mp4'), filename: 'flower.mp4', content_type: 'video/mp4')
    end
  end

  # 組織テックリーダーズのオーナーが投稿したビデオ
  factory :another_video, class: 'Video' do
    title { 'アナザービデオ' }
    open_period { nil }
    expire_type { 0 }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 2 }
    user_id { 2 }
    organization
    user

    # afterメソッド。Videoインスタンスをbuildした後、動画をつける。
    after(:build) do |another_video|
      another_video.video.attach(io: File.open('spec/fixtures/files/flower.mp4'), filename: 'flower.mp4', content_type: 'video/mp4')
    end
  end
end
