class Organization < ApplicationRecord
  has_many :users, dependent: :destroy, autosave: true
  has_many :organization_viewers, dependent: :destroy
  has_many :organization_loginless_viewers, dependent: :destroy

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :name,  presence: true, length: { in: 1..10 }

  # 引数のviewer_idと一致するorganizationの絞り込み
  scope :viewer_has, ->(viewer_id) { includes(:organization_viewers).where(organization_viewers: { viewer_id: viewer_id }) }
  scope :viewer_existence_confirmation, ->(viewer_id) { find_by(organization_viewers: { viewer_id: viewer_id }) }
  scope :linked_arguments, ->(loginless_viewer_id) { where(organization_loginless_viewers: { loginless_viewer_id: loginless_viewer_id }) }
  scope :loginless_viewer_has, ->(loginless_viewer_id) { includes(:organization_loginless_viewers).linked_arguments(loginless_viewer_id) }

  # 組織に属するオーナーを紐づける
  class << self
    def build(params)
      organization = new(name: params[:name], email: params[:email])
      organization.users.build(params[:users])
      organization
    end
  end

  # 組織の退会時、所属者全員退会にするメソッド
  def self.bulk_update(organization_id)
    all_valid = true
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      organization = Organization.find(organization_id).update(is_valid: false)
      user = User.user_has(organization_id).update(is_valid: false)

      viewers = Viewer.viewer_has(organization_id)
      viewers.each do |viewer|
        # 複数所属している場合退会処理にしない
        viewer.update(is_valid: false) if OrganizationViewer.where(viewer_id: viewer.id).count == 1
      end

      loginless_viewers = LoginlessViewer.loginless_viewer_has(organization_id)
      loginless_viewers.each do |loginless_viewer|
        # 複数所属している場合退会処理にしない
        loginless_viewer.update(is_valid: false) if OrganizationLoginlessViewer.where(loginless_viewer_id: loginless_viewer.id).count == 1
      end

      all_valid &= organization && user && viewers && loginless_viewers
      # 全ての処理が有効出ない場合ロールバックする
      unless all_valid
        raise ActiveRecord::Rollback
      end
    end
    all_valid
  end
end
