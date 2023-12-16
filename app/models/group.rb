class Group < ApplicationRecord
  belongs_to :organization
  has_many :viewer_groups
  has_many :group_videos
  has_many :videos, through: :group_videos
  has_many :viewers, through: :viewer_groups, dependent: :destroy

  before_create -> { self.uuid = SecureRandom.uuid }
  validates :name, presence: true
end
