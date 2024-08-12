# frozen_string_literal: true

class Viewer < ApplicationRecord
  has_many :organization_viewers, dependent: :destroy
  has_many :organizations, through: :organization_viewers
  has_many :comments, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :viewer_groups
  has_many :groups, through: :viewer_groups, dependent: :destroy

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :name, presence: true, length: { in: 1..10 }

  # 引数のorganization_idと一致するviewerの絞り込み
  scope :current_owner_has, lambda { |current_user|
    includes(:organization_viewers).where(organization_viewers: { organization_id: current_user.organization_id })
  }

  scope :viewer_has, lambda { |organization_id|
    includes(:organization_viewers).where(organization_viewers: { organization_id: organization_id })
  }

  # 退会者は省く絞り込み
  scope :subscribed, -> { where(is_valid: true) }

  # 管理者かどうかに応じて適切なViewersを取得するメソッド
  def self.for_current_user(user, _organization_id_param)
    current_owner_has(user).subscribed
  end

  def self.for_system_admin(organization_id_param)
    viewer_has(organization_id_param).subscribed
  end

  def ensure_member(organization_id)
    OrganizationViewer.where(viewer_id: self.id, organization_id: organization_id)
  end
end
