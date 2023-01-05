class Reply < ApplicationRecord
  belongs_to :organization
  belongs_to :system_admin, optional: true
  belongs_to :user, optional: true
  belongs_to :viewer, optional: true
  belongs_to :comment

  # バリデーション
  validates :reply, presence: true

  # コメント返信したアカウントのidをセット
  def set_replyer_id
    if current_system_admin && (@account == current_system_admin)
      @reply.system_admin_id = current_system_admin.id   
    elsif current_user && (@account == current_user)
      @reply.user_id = current_user.id
    elsif current_viewer && (@account == current_viewer)
      @reply.viewer_id = current_viewer.id
    end
  end

  # システム管理者またはコメント返信した本人しか編集・削除ができない
  def system_admin_or_correct_replyer(reply)
    unless current_system_admin || reply.user_id == current_user&.id || reply.viewer_id == current_viewer&.id
      errors.add(:reply, ": 権限がありません。")
    end
  end
end
