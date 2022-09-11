class Organization < ApplicationRecord
  has_many :users, dependent: :destroy, autosave: true
  has_many :organization_viewers
  has_many :organization_loginless_viewers

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :name,  presence: true, length: { in: 1..10 }

  class << self
    def build(params)
      organization = new(name: params[:name], email: params[:email])
      organization.users.build(params[:users])
      organization
    end
  end
end
