FactoryBot.define do
  factory :organization_viewer, class: 'OrganizationViewer' do
    id              { 1 }
    organization_id { 1 }
    viewer_id       { 1 }
  end

  factory :organization_viewer1, class: 'OrganizationViewer' do
    id              { 2 }
    organization_id { 2 }
    viewer_id       { 2 }
  end

  factory :organization_viewer2, class: 'OrganizationViewer' do
    id              { 3 }
    organization_id { 1 }
    viewer_id       { 3 }
  end

  factory :organization_viewer3, class: 'OrganizationViewer' do
    id              { 4 }
    organization_id { 2 }
    viewer_id       { 3 }
  end
end
