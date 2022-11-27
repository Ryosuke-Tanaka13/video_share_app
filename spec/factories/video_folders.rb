FactoryBot.define do
  factory :video_folder, class: 'VideoFolder' do
    video_id        { 1 }
    folder_id       { 1 }
  end

  factory :video_folder1, class: 'VideoFolder' do
    video_id        { 1 }
    folder_id       { 2 }
  end

  factory :video_folder2, class: 'VideoFolder' do
    video_id        { 2 }
    folder_id       { 1 }
  end
end
