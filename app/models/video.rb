class Video < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :organization
  belongs_to :user
  has_one_attached :video
  has_many :comments, dependent: :destroy
  has_many :video_folders, dependent: :destroy
  has_many :folders, through: :video_folders
  has_many :questionnaire_answers, dependent: :destroy
  has_many :questionnaire_items, dependent: :destroy
  
  belongs_to :pre_video_questionnaire, -> { with_deleted }, class_name: 'Questionnaire', foreign_key: 'pre_video_questionnaire_id', optional: true
  belongs_to :post_video_questionnaire, -> { with_deleted }, class_name: 'Questionnaire', foreign_key: 'post_video_questionnaire_id', optional: true

  validates :title, presence: true
  validates :title, uniqueness: { scope: :organization }, if: :video_exists?
  validates :video, presence: true, blob: { content_type: :video }

  after_save :create_id_digest

  def to_param
    id_digest
  end

  def video_exists?
    video = Video.where(title: self.title, is_valid: true).where.not(id: self.id)
    video.present?
  end

  scope :user_has, ->(organization_id) { includes(:video_blob).where(organization_id: organization_id) }
  scope :current_user_has, ->(current_user) { includes(:video_blob).where(organization_id: current_user.organization_id) }
  scope :current_viewer_has, ->(organization_id) { includes(:video_blob).where(organization_id: organization_id) }
  scope :available, -> { where(is_valid: true) }

  def identify_organization_and_user(current_user)
    self.organization_id = current_user.organization.id
    self.user_id = current_user.id
  end

  def user_no_available?(current_user)
    self.organization_id != current_user.organization_id
  end

  def my_upload?(current_user)
    self.user_id == current_user.id
  end

  def login_need?
    self.login_set == true
  end

  def valid_true?
    self.is_valid == true
  end

  def not_valid?
    self.is_valid == false
  end

  private

  def create_id_digest
    if id_digest.nil?
      new_digest = Base64.encode64(id.to_s)
      update_column(:id_digest, new_digest)
    end
  end

  scope :search, ->(search_params) {
    return if search_params.blank?
    title_like(search_params[:title_like])
      .open_period_from(search_params[:open_period_from])
      .open_period_to(search_params[:open_period_to])
      .range(search_params[:range])
      .user_like(search_params[:user_name])
  }

  scope :title_like, ->(title) { where('title LIKE ?', "%#{title}%") if title.present? }
  scope :open_period_from, ->(from) { where('? <= open_period', DateTime.parse(from) - 9.hours) if from.present? }
  scope :open_period_to, ->(to) { where('open_period <= ?', DateTime.parse(to) - 9.hours) if to.present? }
  scope :range, ->(range) {
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
