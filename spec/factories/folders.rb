FactoryBot.define do
  factory :folder_celeb, class: 'Folder' do
    name { 'セレブエンジニア' }
    organization_id { 1 }
    video_folder_id { 1 }
  end

  factory :folder_tech, class: 'Folder' do
    name { 'テックリーダーズ' }
    organization_id { 1 }
    video_folder_id { 1 }
  end

  factory :folder_other_owner, class: 'Folder' do
    name { 'IT' }
    organization_id { 1 }
    video_folder_id { 1 }
  end
end
