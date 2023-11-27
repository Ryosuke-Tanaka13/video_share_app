# frozen_string_literal: true

FactoryBot.define do
  factory :viewer, class: 'Viewer' do
    name     { '視聴者' }
    email    { 'viewer_spec@example.com' }
    password { 'password' }
  end

  factory :another_viewer, class: 'Viewer' do
    name     { '他の視聴者' }
    email    { 'viewer_spec1@example.com' }
    password { 'password' }
  end

  factory :viewer1, class: 'Viewer' do
    name     { '視聴者1' }
    email    { 'viewer_spec2@example.com' }
    password { 'password' }
  end
end
