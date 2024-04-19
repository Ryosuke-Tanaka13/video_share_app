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
    
    after(:build) do |video|
      video.video.attach(io: File.open('spec/fixtures/files/video_jan_public_owner.mp4'), filename: 'video_jan_public_owner.mp4', content_type: 'video/mp4')
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

    after(:build) do |video|
      video.video.attach(io: File.open('spec/fixtures/files/invalid_video_jan_public_owner.mp4'), filename: 'invalid_video_jan_public_owner.mp4', content_type: 'video/mp4')
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

    after(:build) do |video_sample|
      video_sample.video.attach(io: File.open('spec/fixtures/files/flower.mp4'), filename: 'flower.mp4', content_type: 'video/mp4')
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

    after(:build) do |video|
      video.video.attach(io: File.open('spec/fixtures/files/video_mar_public_staff.mp4'), filename: 'video_mar_public_staff.mp4', content_type: 'video/mp4')
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

    after(:build) do |video|
      video.video.attach(io: File.open('spec/fixtures/files/video_apr_private_staff.mp4'), filename: 'video_apr_private_staff.mp4', content_type: 'video/mp4')
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

    after(:build) do |video|
      video.video.attach(io: File.open('spec/fixtures/files/video_may_public_staff1.mp4'), filename: 'video_may_public_staff1.mp4', content_type: 'video/mp4')
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

    after(:build) do |video|
      video.video.attach(io: File.open('spec/fixtures/files/another_video_jan_public_another_user_owner.mp4'), filename: 'another_video_jan_public_another_user_owner.mp4', content_type: 'video/mp4')
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

    after(:build) do |video|
      video.video.attach(io: File.open('spec/fixtures/files/another_video_feb_private_another_user_staff.mp4'), filename: 'another_video_feb_private_another_user_staff.mp4', content_type: 'video/mp4')
    end
  end
end