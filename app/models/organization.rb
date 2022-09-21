class Organization < ApplicationRecord
  has_many :users, dependent: :destroy, autosave: true
  has_many :organization_viewers, dependent: :destroy
  has_many :organization_loginless_viewers, dependent: :destroy

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :name,  presence: true, length: { in: 1..10 }

  # 引数のviewer_idと一致するorganizationの絞り込み
  scope :viewer_has, ->(viewer_id) { includes(:organization_viewers).where(organization_viewers: { viewer_id: viewer_id }) }
  scope :loginless_viewer_has, ->(loginless_viewer_id) { includes(:organization_loginless_viewers).where(organization_loginless_viewers: { loginless_viewer_id: loginless_viewer_id }) }
  scope :viewer_existence_confirmation, lambda { |viewer_id|
                                          includes(:organization_viewers).find_by(organization_viewers: { viewer_id: viewer_id })
                                        }
  scope :loginless_viewer_existence_confirmation, lambda { |loginless_viewer_id|
                                          includes(:organization_loginless_viewers).find_by(organization_loginless_viewers: { loginless_viewer_id: loginless_viewer_id })
                                        }
                                        

  class << self
    def build(params)
      organization = new(name: params[:name], email: params[:email])
      organization.users.build(params[:users])
      organization
    end
  end
end
