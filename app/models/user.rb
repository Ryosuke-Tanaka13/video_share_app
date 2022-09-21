# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable

  # 初期値 owner
  enum role: { owner: 0, staff: 1 }

  belongs_to :organization

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :name,  presence: true, length: { in: 1..10 }

  scope :current_owner_has, ->(current_user) { where(organization_id: current_user.organization_id) }
  scope :unsubscribe, -> { where(is_valid: true) }
end
