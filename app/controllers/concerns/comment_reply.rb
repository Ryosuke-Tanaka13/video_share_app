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

  # システム管理者、動画投稿者または動画視聴者のみ許可
  def ensure_system_admin_or_user_or_viewer
    @video = Video.find(params[:video_id])
    if current_system_admin.blank? && current_user.blank? && current_viewer.blank?
      redirect_to video_url(@video.id), flash: { danger: '権限がありません' }
    end
  end

  # video_idを元に動画情報をセット
  def set_video_id
    @video = Video.find(params[:video_id])
  end
end
