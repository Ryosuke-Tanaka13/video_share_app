class OrganizationLoginlessViewer < ApplicationRecord
  belongs_to :organization
  belongs_to :loginless_viewer
end
