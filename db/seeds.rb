# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# system_admin関連==================================================
system_admin = SystemAdmin.new(
  email: 'test_system_admin@gmail.com',
  name: '小松和貴',
  password: 'password'
)
system_admin.skip_confirmation! # deviseの確認メールをスキップ
system_admin.save!

# =================================================================
# organization関連==================================================
organization = Organization.new(
  email: "test_organization1@gmail.com",
  name: "セレブエンジニア"
)
organization.save!

organization = Organization.new(
  email: "test_organization2@gmail.com",
  name: "テックリーダーズ"
)
organization.save!

# =================================================================
# user関連==================================================
user = User.new(
  email: 'test_user_owner1@gmail.com',
  name: 'オーナー1',
  password: 'password',
  role: 0,
  organization_id: 1  
)
user.skip_confirmation! # deviseの確認メールをスキップ
user.save!

user = User.new(
  email: 'test_user1@gmail.com',
  name: 'スタッフ1',
  password: 'password',
  role: 1,
  organization_id: 1 
)
user.skip_confirmation! # deviseの確認メールをスキップ
user.save!

user = User.new(
  email: 'test_user_owner2@gmail.com',
  name: 'オーナー2',
  password: 'password',
  role: 0,
  organization_id: 2
)
user.skip_confirmation! # deviseの確認メールをスキップ
user.save!

user = User.new(
  email: 'test_user2@gmail.com',
  name: 'スタッフ2',
  password: 'password',
  role: 1,
  organization_id: 2
)
user.skip_confirmation! # deviseの確認メールをスキップ
user.save!

# =================================================================
# viewer関連==================================================
3.times do |i|
  viewer = Viewer.new(
    email: "test_viewer#{i}@gmail.com",
    name: "視聴者#{i}",
    password: 'password'
  )
  viewer.skip_confirmation! # deviseの確認メールをスキップ
  viewer.save!
end

organization_viewer = OrganizationViewer.new(
  organization_id: 1,
  viewer_id: 1
)
organization_viewer.save!

organization_viewer = OrganizationViewer.new(
  organization_id: 2,
  viewer_id: 2
)
organization_viewer.save!

organization_viewer = OrganizationViewer.new(
  organization_id: 1,
  viewer_id: 3
)
organization_viewer.save!

organization_viewer = OrganizationViewer.new(
  organization_id: 2,
  viewer_id: 3
)
organization_viewer.save!

# =================================================================
# video関連==================================================
video1 = Video.new(title: "flower", organization_id: 1, user_id: 1)
video1.video.attach(io: File.open('public/flower.mp4'), filename: 'flower.mp4')
video1.save

video2 = Video.new(title: "aurora", organization_id: 1, user_id: 1)
video2.video.attach(io: File.open('public/aurora.mp4'), filename: 'aurora.mp4')
video2.save

video3 = Video.new(title: "sea", organization_id: 2, user_id: 3)
video3.video.attach(io: File.open('public/sea.mp4'), filename: 'sea.mp4')
video3.save

video4 = Video.new(title: "snow", organization_id: 2, user_id: 3)
video4.video.attach(io: File.open('public/snow.mp4'), filename: 'snow.mp4')
video4.save

# =================================================================
# video関連 ========================================================
Video.create!(
  title: 'テストビデオ',
  open_period: 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00',
  range: false,
  comment_public: false,
  login_set: false,
  popup_before_video: false,
  popup_after_video: false,
  organization_id: 1,
  user_id: 1,
  # vimeoへの動画データのアップロードは行わず。(vimeoに動画データがなくても、data_urlを仮で設定しておけば、アプリ内ではインスタンスが存在可能)
  data_url: '/videos/444444444'
)
