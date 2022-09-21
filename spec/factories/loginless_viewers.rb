FactoryBot.define do
  factory :loginless_viewer, class: 'LoginlessViewer' do
    id       { 1 }
    name     { 'ログインなし' }
    email    { 'less_spec@example.com' }
  end

  factory :another_loginless_viewer, class: 'LoginlessViewer' do
    id       { 2 }
    name     { '他のログインなし' }
    email    { 'less_spec1@example.com' }
  end

  factory :loginless_viewer1, class: 'LoginlessViewer' do
    id       { 3 }
    name     { 'ログインなし1' }
    email    { 'less_spec2@example.com' }
  end
end
