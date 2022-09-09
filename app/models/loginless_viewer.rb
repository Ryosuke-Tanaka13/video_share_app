class LoginlessViewer < ApplicationRecord
  has_many :organization_loginless_viewers

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :name,  presence: true, uniqueness: true, length: { in: 3..10 }
end
