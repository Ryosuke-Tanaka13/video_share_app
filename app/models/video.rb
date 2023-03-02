class Video < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  has_one_attached :video

  validates :title, presence: true
  validates :title, uniqueness: { scope: :organization }, if: :video_exists?
  validates :video, presence: true, blob: { content_type: :video }
  validate :open_period_is_greater_than_time_now

  # 初期値 private
  enum expire_type: { nonpublic: 0, deactivate: 1 }

  def video_exists?
    video = Video.where(title: self.title, is_valid: true).where.not(id: self.id)
    video.present?
  end

  def open_period_is_greater_than_time_now
    errors.add(:open_period, 'は現在時刻より後の日時を選択してください') if open_period&.<= Time.now
  end

  scope :user_has, lambda { |organization_id|
    includes(:video_blob).where(organization_id: organization_id)
  }

  scope :current_user_has, lambda { |current_user|
    includes(:video_blob).where(organization_id: current_user.organization_id)
  }

  scope :not_expire, -> { where('open_period > ?', Time.current) }
  scope :free_open_period, -> { where(open_period: nil) }

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
