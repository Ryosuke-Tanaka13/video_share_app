class Comment < ApplicationRecord
  belongs_to :system_admin, optional: true
  belongs_to :user, optional: true
  belongs_to :viewer, optional: true
  belongs_to :organization
  belongs_to :video

  has_many :replies, dependent: :destroy

  # バリデーション
  validates :comment, presence: true
  validate :ensure_account_present

  def ensure_account_present
    errors.add("問題が発生しました。") if (system_admin_id.blank? && user_id.blank? && viewer_id.blank?)
  end
  # TODO: エラー発生のため改修が必要　CommentsControllerで一旦制御
  # validate :system_admin_or_correct_commenter
  # attr_accessor :current_system_admin, :current_user, :current_viewer

  # # システム管理者またはコメントした本人しか編集・削除ができない
  # def system_admin_or_correct_commenter
  #   if !current_system_admin.present? && self.user_id != current_user&.id && self.viewer_id != current_viewer&.id
  #     errors.add(:comment, ": 権限がありません。")
  #   end
  # end
end
