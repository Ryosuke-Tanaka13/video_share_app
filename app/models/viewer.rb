# frozen_string_literal: true

class Viewer < ApplicationRecord
  has_many :organization_viewers, dependent: :destroy
  has_many :organizations, through: :organization_viewers
  has_many :comments, dependent: :destroy
  has_many :replies, dependent: :destroy

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable,
    :omniauthable, omniauth_providers: %i[google_oauth2]

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :name,  presence: true, length: { in: 1..10 }

  # 引数のorganization_idと一致するviewerの絞り込み
  scope :current_owner_has, lambda { |current_user|
                              includes(:organization_viewers).where(organization_viewers: { organization_id: current_user.organization_id })
                            }
  scope :viewer_has, lambda { |organization_id|
                       includes(:organization_viewers).where(organization_viewers: { organization_id: organization_id })
                     }
  # 退会者は省く絞り込み
  scope :subscribed, -> { where(is_valid: true) }

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |viewer|
      # ※deviseのuserカラムに nameやprofile を追加している場合は下のコメントアウトを外して使用

      viewer.name = auth.info.name
      # viewer.profile = auth.info.profile
      viewer.email = auth.info.email
      viewer.password = Devise.friendly_token[0, 20]
    end
  end
end
