FactoryBot.define do
  # 組織セレブエンジニアのオーナーが投稿したビデオ
  factory :video_sample, class: 'Video' do
    title { 'サンプルビデオ' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
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
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
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

  factory :video_popup_before_test, class: 'Video' do
    title { 'テストビデオ1' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { true }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 3 }
    organization
    user
    # vimeoへの動画データのアップロードは行わず。(vimeoに動画データがなくても、data_urlを仮で設定しておけば、アプリ内ではインスタンスが存在可能)
    data_url { '/videos/222222222' }
  end

  factory :video_popup_after_test, class: 'Video' do
    title { 'テストビデオ2' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { true }
    organization_id { 1 }
    user_id { 3 }
    organization
    user
    # vimeoへの動画データのアップロードは行わず。(vimeoに動画データがなくても、data_urlを仮で設定しておけば、アプリ内ではインスタンスが存在可能)
    data_url { '/videos/222222222' }
  end

  factory :video_popup_before_test, class: 'Video' do
    title { 'テストビデオ1' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { true }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 3 }
    organization
    user
    # vimeoへの動画データのアップロードは行わず。(vimeoに動画データがなくても、data_urlを仮で設定しておけば、アプリ内ではインスタンスが存在可能)
    data_url { '/videos/222222222' }
  end

  factory :video_popup_after_test, class: 'Video' do
    title { 'テストビデオ2' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { true }
    organization_id { 1 }
    user_id { 3 }
    organization
    user
    # vimeoへの動画データのアップロードは行わず。(vimeoに動画データがなくても、data_urlを仮で設定しておけば、アプリ内ではインスタンスが存在可能)
    data_url { '/videos/222222222' }
  end

  factory :video_it, class: 'Video' do
    title { 'ITビデオ' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
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
    after(:build) do |video_it|
      video_it.video.attach(io: File.open('spec/fixtures/files/flower.mp4'), filename: 'flower.mp4', content_type: 'video/mp4')
    end
  end

  # 組織セレブエンジニアのオーナーが投稿したビデオ(論理削除されたもの)
  factory :video_deleted, class: 'Video' do
    title { 'デリートビデオ' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
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
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
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
