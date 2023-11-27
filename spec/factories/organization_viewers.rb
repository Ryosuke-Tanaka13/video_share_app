FactoryBot.define do
  factory :organization_viewer, class: 'OrganizationViewer' do
    organization_id { 1 }
    viewer_id       { 1 }
  end

  factory :organization_viewer1, class: 'OrganizationViewer' do
    organization_id { 2 }
    viewer_id       { 2 }
  end

  factory :organization_viewer2, class: 'OrganizationViewer' do
    organization_id { 1 }
    viewer_id       { 3 }
  end

  factory :organization_viewer3, class: 'OrganizationViewer' do
    organization_id { 2 }
    viewer_id       { 3 }
  end
end
