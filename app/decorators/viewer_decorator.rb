# frozen_string_literal: true

module ViewerDecorator
  # 視聴率一覧ページで呼び出し
  def complete_video_status(video_id)
    VideoStatus.find_by(video_id: video_id, viewer_id: self.id, watched_ratio: 100.0)
  end

  def incomplete_video_status(video_id)
    VideoStatus.find_by(video_id: video_id, viewer_id: self.id, watched_ratio: ...100.0)
  end

  def not_zero_video_status(video_id)
    VideoStatus.where.not(watched_ratio: 0.0).find_by(video_id: video_id, viewer_id: self.id)
  end

  def name_show
    if current_user&.owner? || current_system_admin
      link_to self.name, viewer_path(self)
    else
      self.name
    end
  end

  def not_valid_flag
    if current_system_admin && (self.is_valid == false)
      '(退会)'
    end
  end

  def incomplete_video_status_watched_ratio(video_id)
    self.incomplete_video_status(video_id).watched_ratio if self.incomplete_video_status(video_id).present?
  end
end
