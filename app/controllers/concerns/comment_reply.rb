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

  # 動画投稿者または動画視聴者のみ許可
  def ensure_user_or_viewer
    @video= Video.find(params[:video_id])
    if current_user.blank? && current_viewer.blank?
      redirect_to video_url(@video.id), flash: { danger: '権限がありません' }
    end
  end

  # video_idを元に動画情報をセット
  def set_video_id
    @video = Video.find(params[:video_id])
  end
  
end 