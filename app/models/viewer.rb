# frozen_string_literal: true

class Viewer < ApplicationRecord
  has_many :organization_viewers, dependent: :destroy
  has_many :organizations, through: :organization_viewers

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable,
    :confirmable

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: { if: :viewer_exists? }, format: { with: VALID_EMAIL_REGEX }
  validates :name,  presence: true, length: { in: 1..10 }
  validates :password, presence: true, length: { in: 6..128 }, confirmation: true, on: :create

  # 引数のorganization_idと一致するviewerの絞り込み
  scope :current_owner_has, lambda { |current_user|
                              includes(:organization_viewers).where(organization_viewers: { organization_id: current_user.organization_id })
                            }
  scope :viewer_has, lambda { |organization_id|
                       includes(:organization_viewers).where(organization_viewers: { organization_id: organization_id })
                     }
  # 退会者は省く絞り込み
  scope :subscribed, -> { where(is_valid: true) }

  # アクティブviewerと同じemailが存在すればtrueを返す（trueでuniqueness検知する）
  def viewer_exists?
    viewer = Viewer.subscribed.where(email: self.email).where.not(id: self.id)
    viewer.present?
  end

  # session#create時経由　論理削除状態を参照しないように仕様変更
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    if login
      where(conditions).where(['lower(email) = lower(:email)', { email: email }]).subscribed.first
    else
      where(conditions).subscribed.first
    end
  end
end
