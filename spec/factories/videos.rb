FactoryBot.define do
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

    after(:build) do |video_sample|
      video_sample.video.attach(io: File.open('spec/fixtures/files/rec.webm'), filename: 'rec.webm', content_type: 'video/webm')
    end
  end

  factory :video_test, class: 'Video' do
    title { 'テストビデオ' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { true }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 3 }
    organization
    user

    after(:build) do |video_test|
      video_test.video.attach(io: File.open('spec/fixtures/files/rec.webm'), filename: 'rec.webm', content_type: 'video/webm')
    end
  end
end
