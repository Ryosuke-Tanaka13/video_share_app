class Video < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  has_one_attached :video
  has_many :comments, dependent: :destroy

  has_many :video_folders, dependent: :destroy
  has_many :folders, through: :video_folders

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

  # ビデオ検索機能
  scope :search, lambda { |search_params|
    # 検索フォームが空であれば何もしない
    return if search_params.blank?

    # ひらがな・カタカナは区別しない
    title_like(search_params[:title_like])
      .open_period_from(search_params[:open_period_from])
      .open_period_to(search_params[:open_period_to])
      .range(search_params[:range])
      .user_like(search_params[:user_name])
  }

  scope :title_like, ->(title) { where('title LIKE ?', "%#{title}%") if title.present? }
  # DBには世界時間で検索されるため9時間マイナスする必要がある
  scope :open_period_from, ->(from) { where('? <= open_period', DateTime.parse(from) - 9.hours) if from.present? }
  scope :open_period_to, ->(to) { where('open_period <= ?', DateTime.parse(to) - 9.hours) if to.present? }
  scope :range, lambda { |range|
    if range.present?
      if range == 'all'
        nil
      else
        where(range: range)
      end
    end
  }
  scope :user_like, ->(user_name) { joins(:user).where('users.name LIKE ?', "%#{user_name}%") if user_name.present? }
end
