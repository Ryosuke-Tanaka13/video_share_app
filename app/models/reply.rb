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
end
