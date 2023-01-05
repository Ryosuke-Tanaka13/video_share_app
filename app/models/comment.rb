class Comment < ApplicationRecord
  belongs_to :system_admin, optional: true
  belongs_to :user, optional: true
  belongs_to :viewer, optional: true
  belongs_to :organization
  belongs_to :video

  has_many :replies, dependent: :destroy

  # バリデーション
  validates :comment, presence: true
  validates :system_admin_or_correct_commenter

  # コメントしたアカウントidをセット
  def set_commenter_id
    if current_system_admin && (@account == current_system_admin)
      @comment.system_admin_id = current_system_admin.id
    elsif current_user && (@account == current_user)
      @comment.user_id = current_user.id
    elsif current_viewer && (@account == current_viewer)
      @comment.viewer_id = current_viewer.id
    end
  end

  # システム管理者またはコメントした本人しか編集・削除ができない
  def system_admin_or_correct_commenter(comment)
    unless current_system_admin || comment.user_id == current_user&.id || comment.viewer_id == current_viewer&.id
      errors.add(:comment, ": 権限がありません。")
    end
  end
end
