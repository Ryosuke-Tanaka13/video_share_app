class Video < ApplicationRecord
  include ApplicationHelper

  belongs_to :organization
  belongs_to :user

  has_one_attached :video

  validates :title, presence: true, uniqueness: { scope: :organization }
  # videoのuniqueness設定は別の方法が必要
  validates :video, presence: true
  
  scope :current_owner_has, ->(current_user) { where(organization_id: current_user.organization_id) }

  def identify_organization_and_user(current_user)
    self.organization_id = current_user.organization.id 
    self.user_id = current_user.id
  end

  def owner_has?(current_user)
    return true if self.organization_id == current_user.organization_id
    false
  end
end
