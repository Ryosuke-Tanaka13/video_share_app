class Video < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  has_one_attached :video
  validates :title, presence: true
  validates :title, uniqueness: { scope: :organization }, if: :video_exists?
  validates :video, presence: true, blob: { content_type: :video }

  # saveが完了した後に呼び出されるコールバック
  after_save :create_id_digest

  # showやeditページへのリンクを踏んだ際に呼び出される。idではなく、id_digestを渡せるようになる。
  def to_param
    id_digest
  end

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

  private
  # after_saveによって呼び出されるメソッド。id_digestカラムの値に、idを暗号化して格納
  def create_id_digest
    if id_digest.nil?
      new_digest = Base64.encode64(id.to_s)
      update_column(:id_digest, new_digest)
    end
  end
end
