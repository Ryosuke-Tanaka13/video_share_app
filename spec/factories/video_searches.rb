FactoryBot.define do
  factory :video_jan_public_owner, class: 'Video' do
    title { 'テスト動画1月' }
    open_period { 'Tue, 31 Jan 2023 23:59:00.000000000 JST +09:00' }
    range { true }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 1 }
    after(:build) do |video_jan_public_owner|
      video_jan_public_owner.video.attach(io: File.open('spec/fixtures/files/flower.mp4'), filename: 'flower.mp4', content_type: 'video/mp4')
    end
  end

  factory :invalid_video_jan_public_owner, class: 'Video' do
    title { 'テスト動画1月（論理削除済み）' }
    open_period { 'Tue, 31 Jan 2023 23:59:00.000000000 JST +09:00' }
    range { true }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { false }
    is_valid { false }
    organization_id { 1 }
    user_id { 1 }
    after(:build) do |invalid_video_jan_public_owner|
      invalid_video_jan_public_owner.video.attach(io: File.open('spec/fixtures/files/flower.mp4'), filename: 'flower.mp4', content_type: 'video/mp4')
    end
  end

  factory :video_feb_private_owner, class: 'Video' do
    title { 'テスト動画2月' }
    open_period { 'Tue, 28 Feb 2023 23:59:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 1 }
    after(:build) do |video_feb_private_owner|
      video_feb_private_owner.video.attach(io: File.open('spec/fixtures/files/flower.mp4'), filename: 'flower.mp4', content_type: 'video/mp4')
    end
  end

  factory :video_mar_public_staff, class: 'Video' do
    title { 'テスト動画3月' }
    open_period { 'Fri, 31 Mar 2023 23:59:00.000000000 JST +09:00' }
    range { true }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 3 }
    after(:build) do |video_mar_public_staff|
      video_mar_public_staff.video.attach(io: File.open('spec/fixtures/files/flower.mp4'), filename: 'flower.mp4', content_type: 'video/mp4')
    end
  end

  factory :video_apr_private_staff, class: 'Video' do
    title { 'テスト動画4月' }
    open_period { 'Sun, 30 Apr 2023 23:59:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 3 }
    after(:build) do |video_apr_private_staff|
      video_apr_private_staff.video.attach(io: File.open('spec/fixtures/files/flower.mp4'), filename: 'flower.mp4', content_type: 'video/mp4')
    end
  end

  factory :video_may_public_staff1, class: 'Video' do
    title { 'テスト動画5月' }
    open_period { 'Wed, 31 May 2023 23:59:00.000000000 JST +09:00' }
    range { true }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 4 }
    after(:build) do |video_may_public_staff1|
      video_may_public_staff1.video.attach(io: File.open('spec/fixtures/files/flower.mp4'), filename: 'flower.mp4', content_type: 'video/mp4')
    end
  end

  factory :another_video_jan_public_another_user_owner, class: 'Video' do
    title { 'テスト動画1月（組織外）' }
    open_period { 'Tue, 31 Jan 2023 23:59:00.000000000 JST +09:00' }
    range { true }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 2 }
    user_id { 2 }
    after(:build) do |another_video_jan_public_another_user_owner|
      another_video_jan_public_another_user_owner.video.attach(io: File.open('spec/fixtures/files/flower.mp4'), filename: 'flower.mp4', content_type: 'video/mp4')
    end
  end

  factory :another_video_feb_private_another_user_staff, class: 'Video' do
    title { 'テスト動画2月（組織外）' }
    open_period { 'Tue, 28 Feb 2023 23:59:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 2 }
    user_id { 5 }
    after(:build) do |another_video_feb_private_another_user_staff|
      another_video_feb_private_another_user_staff.video.attach(io: File.open('spec/fixtures/files/flower.mp4'), filename: 'flower.mp4', content_type: 'video/mp4')
    end
  end
end
