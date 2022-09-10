# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

organization = Organization.new(
  email: 'test_organization@gmail.com',
  name: 'セレブエンジニア'
)

organization.save!

user = User.new(
  email: 'test_user1@gmail.com',
  name: 'オーナー',
  password: 'password',
  role: 1,
  organization_id: 1
)

user.skip_confirmation! # deviseの確認メールをスキップ
user.save!

system_admin = SystemAdmin.new(
  email: 'test_system_admin@gmail.com',
  name: '小松和貴',
  password: 'password'
)
system_admin.skip_confirmation! # deviseの確認メールをスキップ
system_admin.save!

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
