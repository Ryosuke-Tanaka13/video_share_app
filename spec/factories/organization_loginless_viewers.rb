FactoryBot.define do
  factory :organization_loginless_viewer, class: 'OrganizationLoginlessViewer' do
    id                  { 1 }
    organization_id     { 1 }
    loginless_viewer_id { 1 }
  end

  factory :organization_loginless_viewer1, class: 'OrganizationLoginlessViewer' do
    id                  { 2 }
    organization_id     { 2 }
    loginless_viewer_id { 2 }
  end

  factory :organization_loginless_viewer2, class: 'OrganizationLoginlessViewer' do
    id                  { 3 }
    organization_id     { 1 }
    loginless_viewer_id { 3 }
  end

  factory :organization_loginless_viewer3, class: 'OrganizationLoginlessViewer' do
    id                  { 4 }
    organization_id     { 2 }
    loginless_viewer_id { 3 }
  end
end
