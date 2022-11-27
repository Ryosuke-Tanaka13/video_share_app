class Folder < ApplicationRecord
  belongs_to :organization
  has_many :video_folders, dependent: :destroy
  has_many :videos, through: :video_folders
  validates :name, presence: true, uniqueness: { scope: :organization }

  scope :current_user_has, ->(current_user) { where(organization_id: current_user.organization_id) }
  scope :assigned_by_the_video_setting, ->(video) { where(organization_id: video.organization_id) }
  scope :available, -> { where(is_valid: true) }

  def create(current_user)
    self.organization_id = current_user.organization_id
    self.save
  end
end
