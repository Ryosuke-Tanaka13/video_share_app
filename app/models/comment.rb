class Comment < ApplicationRecord
  belongs_to :system_admin, optional: true
  belongs_to :user, optional: true
  belongs_to :viewer, optional: true
  belongs_to :organization
  belongs_to :video

  has_many :replies, dependent: :destroy

  # バリデーション
  validates :comment, presence: true

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
end
