class Comment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :viewer, optional: true
  belongs_to :organization
  belongs_to :video

  has_many :replies, dependent: :destroy

  # バリデーション
  validates :comment, presence: true


  # コメントするアカウントをセット
  def set_current_user_type
    @current_user_type = (current_user || current_viewer || current_loginless_viewer)
  end

  # コメントしたアカウントのidをセット
  def set_commenter_id
    current_user_type = (current_user || current_viewer || current_loginless_viewer)
    if current_user_type == current_user
      @comment.user_id = current_user.id
    elsif current_user_type == current_viewer
      @comment.viewer_id = current_viewer.id
    else
      @comment.loginless_viewer_id = current_loginless_viewer.id
    end
  end

  # コメントしたアカウントと一致するか判定
  def correct_commenter?
    @current_user_type.id == comment.user_id || @current_user_type.id == comment.viewer_id || @current_user_type.id == comment.loginless_viewer_id
  end

end
