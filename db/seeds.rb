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
# 視聴率取得の挙動を確認しやすいようにviewerを追加==================================================
viewerA = Viewer.new(
  email: "test_viewerA@gmail.com",
  name: "視聴者A",
  password: 'password'
)
viewerA.skip_confirmation! # deviseの確認メールをスキップ
viewerA.save!

viewerB = Viewer.new(
  email: "test_viewerB@gmail.com",
  name: "視聴者B",
  password: 'password'
)
viewerB.skip_confirmation! # deviseの確認メールをスキップ
viewerB.save!

viewerC = Viewer.new(
  email: "test_viewerC@gmail.com",
  name: "視聴者C",
  password: 'password'
)
viewerC.skip_confirmation! # deviseの確認メールをスキップ
viewerC.save!

viewerD = Viewer.new(
  email: "test_viewerD@gmail.com",
  name: "視聴者D",
  password: 'password'
)
viewerD.skip_confirmation! # deviseの確認メールをスキップ
viewerD.save!

viewerE = Viewer.new(
  email: "test_viewerE@gmail.com",
  name: "視聴者E",
  password: 'password'
)
viewerE.skip_confirmation! # deviseの確認メールをスキップ
viewerE.save!

organization_viewer = OrganizationViewer.new(
  organization_id: 1,
  viewer_id: 4
)
organization_viewer.save!

organization_viewer = OrganizationViewer.new(
  organization_id: 1,
  viewer_id: 5
)
organization_viewer.save!

organization_viewer = OrganizationViewer.new(
  organization_id: 1,
  viewer_id: 6
)
organization_viewer.save!

organization_viewer = OrganizationViewer.new(
  organization_id: 1,
  viewer_id: 7
)
organization_viewer.save!

organization_viewer = OrganizationViewer.new(
  organization_id: 1,
  viewer_id: 8
)
organization_viewer.save!
# =================================================================
