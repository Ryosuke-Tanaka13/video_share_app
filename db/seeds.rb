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


5.times do |i|
  viewer = Viewer.new(
    email: "test_viewer#{i}@gmail.com", # sample: test_viewer1@gmail.com
    name: "視聴者#{i}",
    password: 'password'
  )

  viewer.skip_confirmation! # deviseの確認メールをスキップ
  viewer.save!
end

LoginlessViewer.create!(
  name: 'ログインなし視聴者',
  email: 'test_loginless_viewer@gmail.com'
)

Video.create!(
  video: 'https//www.youtube.com',
  title: 'テスト動画',
  user_id: 1,
  organization_id: 1
)
