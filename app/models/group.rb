class Group < ApplicationRecord
  belongs_to :organization
  has_many :viewer_groups
  has_many :viewers, through: :viewer_groups,dependent: :destroy
end
