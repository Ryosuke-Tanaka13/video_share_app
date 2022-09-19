module VideosHelper
  def selected_before_range
    return ['限定公開',1] if @video.range == true
  end

  def selected_before_comment_public
    return ['非公開',1] if @video.comment_public == true
  end

  def selected_before_login_set
    return ['ログイン必要',1] if @video.login_set == true
  end

  def selected_before_popup_before_video 
    return ['動画視聴開始時ポップアップ非表示',1] if @video.popup_before_video == true
  end

  def selected_before_popup_after_video
    return ['動画視聴終了時ポップアップ非表示',1] if @video.popup_after_video == true
  end

  def my_upload?(current_user)
    return true if @video.user_id == current_user.id

    false
  end

  def ensure_owner?(current_user)
    return true if current_user.role == 'owner'

    false
  end
end
