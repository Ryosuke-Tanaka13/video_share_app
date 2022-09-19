module CommentReply
  extend ActiveSupport::Concern

  # 現在ログインしているアカウントをセット(システム管理者を除く)
  def set_account
    if current_user.present?
      @account = current_user
    elsif current_viewer.present?
      @account = current_viewer
    end
  end

  # ログインしているか判定(システム管理者を除く)
  def account_logged_in?
    current_user.present? || current_viewer.present?
  end
  
end 