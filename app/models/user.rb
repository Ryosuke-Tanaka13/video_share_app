# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable,
    :confirmable

  # 初期値 owner
  enum role: { owner: 0, staff: 1 }

  belongs_to :organization
  has_many :videos, dependent: :nullify

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: { if: :user_exists? }, format: { with: VALID_EMAIL_REGEX }
  validates :name, presence: true, length: { in: 1..10 }
  validates :password, presence: true, length: { in: 6..128 }, confirmation: true, on: :create

  # 引数のorganization_idと一致するuserの絞り込み
  scope :current_owner_has, ->(current_user) { where(organization_id: current_user.organization_id) }
  scope :user_has, ->(organization_id) { includes([:organization]).where(organization_id: organization_id) }
  # 退会者は省く絞り込み
  scope :subscribed, -> { where(is_valid: true) }

  # アクティブuserと同じemailが存在すればtrueを返す（trueでuniqueness検知する）
  def user_exists?
    user = User.subscribed.where(email: self.email).where.not(id: self.id)
    user.present?
  end
end
