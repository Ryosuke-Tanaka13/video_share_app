# frozen_string_literal: true

class LoginlessViewer < ApplicationRecord
  has_many :organization_loginless_viewers, dependent: :destroy

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :name,  presence: true, length: { in: 1..10 }

  # 引数のorganization_idと一致するloginless_viewerの絞り込み
  scope :current_owner_has, ->(current_user) { where(organization_loginless_viewers: { organization_id: current_user.organization_id }) }
  scope :linked_loginless_viewer, ->(organization_id) { where(organization_loginless_viewers: { organization_id: organization_id }) }
  scope :loginless_viewer_has, ->(organization_id) { includes(:organization_loginless_viewers).linked_loginless_viewer(organization_id) }

  # 退会者は省く絞り込み
  scope :subscribed, -> { where(is_valid: true) }
end
