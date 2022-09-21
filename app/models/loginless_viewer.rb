class LoginlessViewer < ApplicationRecord
  has_many :organization_loginless_viewers, dependent: :destroy

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :name,  presence: true, length: { in: 1..10 }

  # 引数のorganization_idと一致するloginless_viewerの絞り込み
  scope :current_owner_has, lambda { |current_user|
                              includes(:organization_loginless_viewers).where(organization_loginless_viewers: { organization_id: current_user.organization_id })
                            }
  scope :loginless_viewer_has, lambda { |organization_id|
                       includes(:organization_loginless_viewers).where(organization_loginless_viewers: { organization_id: organization_id })
                     }
  # 退会者は省く絞り込み
  scope :subscribed, -> { where(is_valid: true) }
end
