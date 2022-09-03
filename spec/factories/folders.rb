FactoryBot.define do
  factory :folder_celeb, class: 'Folder' do
    # フォルダー選択時に参照されるため、id追記
    id { 1 }
    name { 'セレブエンジニア' }
    organization_id { 1 }
    video_folder_id { 1 }
  end

  factory :folder_tech, class: 'Folder' do
    id { 2 }
    name { 'テックリーダーズ' }
    organization_id { 1 }
    video_folder_id { 1 }
  end

  factory :folder_other_owner, class: 'Folder' do
    id { 3 }
    name { 'IT' }
    organization_id { 1 }
    video_folder_id { 1 }
  end
end
