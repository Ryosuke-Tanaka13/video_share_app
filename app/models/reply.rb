class Reply < ApplicationRecord
  belongs_to :organization
  belongs_to :system_admin, optional: true
  belongs_to :user, optional: true
  belongs_to :viewer, optional: true
  belongs_to :comment
  # バリデーション
  validates :reply, presence: true
  validate :ensure_account_present

  def ensure_account_present
    errors.add('問題が発生しました。') if system_admin_id.blank? && user_id.blank? && viewer_id.blank?
  end
  # TODO: モデルにメソッド管理できればリファクタリング
  # validate :system_admin_or_correct_replyer

  # システム管理者またはコメント返信した本人しか編集・削除ができない
  # def system_admin_or_correct_replyer(reply)
  #   if !current_system_admin.present?  reply.user_id != current_user&.id && reply.viewer_id != current_viewer&.id
  #     errors.add(:reply, ": 権限がありません。")
  #   end
  # end
end
