# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

50.times do |i|
  viewer = Viewer.new(
    email: "test_viewer#{i}@gmail.com", # sample: test_viewer1@gmail.com
    name: "テストviewer#{i}",
    password: 'password'
  )

  viewer.skip_confirmation! # deviseの確認メールをスキップ
  viewer.save!
end

user = User.new(
  email: 'test_user@gmail.com',
  name: 'テストuser1',
  password: 'password'
)

user.skip_confirmation! # deviseの確認メールをスキップ
user.save!

system_admin = SystemAdmin.new(
  email: 'test_,system_admin@gmail.com',
  name: 'テストsystem_admin1',
  password: 'password'
)

system_admin.skip_confirmation! # deviseの確認メールをスキップ
system_admin.save!
