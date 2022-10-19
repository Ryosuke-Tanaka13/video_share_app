class OrganizationViewer < ApplicationRecord
  belongs_to :organization
  belongs_to :viewer
end
