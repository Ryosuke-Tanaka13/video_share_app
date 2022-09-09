# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

5.times do |i|
  viewer = Viewer.new(
    email: "test_viewer#{i}@gmail.com", # sample: test_viewer1@gmail.com
    name: "視聴者#{i}",
    password: 'password'
  )

  viewer.skip_confirmation! # deviseの確認メールをスキップ
  viewer.save!
end

organization = Organization.new(
  email: 'test_user@gmail.com',
  name: 'セレブエンジニア'
)

organization.save!

user = User.new(
  email: 'test_user_owner@gmail.com',
  name: 'オーナー',
  password: 'password',
  role: 1,
  organization_id: 1      
)

user.skip_confirmation! # deviseの確認メールをスキップ
user.save!

user = User.new(
  email: 'test_user@gmail.com',
  name: '投稿者',
  password: 'password',
  role: 0,
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
