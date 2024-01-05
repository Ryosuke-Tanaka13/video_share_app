module VideosHelper
  def selected_before_range
    return ['限定公開', 1] if @video.range
  end

  def selected_before_login_set
    return ['ログイン必要', 1] if @video.login_set
  end

  def selected_before_popup_before_video
    return ['動画視聴開始時ポップアップ非表示', 1] if @video.popup_before_video
  end

  def selected_before_popup_after_video
    return ['動画視聴終了時ポップアップ非表示', 1] if @video.popup_after_video
  end
end
