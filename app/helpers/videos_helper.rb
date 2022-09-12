module VideosHelper
  def selected_before1
    return 1 if @video.range == true
  end

  def selected_before2
    return 1 if @video.comment_public == true
  end

  def selected_before3
    return 1 if @video.login_set == true
  end

  def selected_before4
    return 1 if @video.popup_before_video == true
  end

  def selected_before5
    return 1 if @video.popup_after_video == true
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
