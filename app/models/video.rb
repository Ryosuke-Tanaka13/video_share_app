class Video < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  has_many :video_statuses, dependent: :destroy
  has_many :viewers, through: :video_statuses

  has_one_attached :video
  has_many :comments, dependent: :destroy

  has_many :video_folders, dependent: :destroy
  has_many :folders, through: :video_folders

  validates :title, presence: true
  validates :title, uniqueness: { scope: :organization }, if: :video_exists?
  validates :video, presence: true, blob: { content_type: :video }

  def video_exists?
    video = Video.where(title: self.title, is_valid: true).where.not(id: self.id)
    video.present?
  end

  scope :user_has, lambda { |organization_id|
    includes(:video_blob).where(organization_id: organization_id)
  }

  scope :current_user_has, lambda { |current_user|
    includes(:video_blob).where(organization_id: current_user.organization_id)
  }

  scope :current_viewer_has, lambda { |organization_id|
    includes(:video_blob).where(organization_id: organization_id)
  }

  scope :available, -> { where(is_valid: true) }

  def identify_organization_and_user(current_user)
    self.organization_id = current_user.organization.id
    self.user_id = current_user.id
  end

  def user_no_available?(current_user)
    return true if self.organization_id != current_user.organization_id

    false
  end

  def my_upload?(current_user)
    return true if self.user_id == current_user.id

    false
  end

  def login_need?
    return true if self.login_set == true

    false
  end

  def valid_true?
    return true if self.is_valid == true

    false
  end

  def not_valid?
    return true if self.is_valid == false

    false
  end
end
