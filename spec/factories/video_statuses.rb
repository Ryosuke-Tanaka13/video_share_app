FactoryBot.define do
  factory :video_sample_status, class: 'VideoStatus' do
    latest_end_point { 6.0 }
    total_time { 12.97 }
    watched_ratio { 46.0 }
    watched_at { nil }
    video_id { 1 }
    viewer_id { 1 }
  end

  factory :video_sample_status1, class: 'VideoStatus' do
    latest_end_point { 12.8548 }
    total_time { 12.97 }
    watched_ratio { 100.0 }
    watched_at { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
    video_id { 1 }
    viewer_id { 3 }
  end

  factory :video_deleted_status, class: 'VideoStatus' do
    latest_end_point { 6.0 }
    total_time { 12.97 }
    watched_ratio { 46.0 }
    watched_at { nil }
    video_id { 4 }
    viewer_id { 1 }
  end
end
