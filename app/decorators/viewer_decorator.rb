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
    if current_user&.role != 'owner'
      self.name
    else
      link_to self.name, viewer_path(self)
    end
  end

  def complete_video_status_hidden_button(video_id)
    if self.complete_video_status(video_id).valid_true?
      link_to '視聴状況の削除', video_status_hidden_path(self.complete_video_status(video_id), video_id: video_id), class: 'btn btn-md btn-danger'
    else
      'オーナー削除済み'
    end
  end

  def incomplete_video_status_watched_ratio(video_id)
    if current_user
      if self.incomplete_video_status(video_id)&.valid_true?
        self.incomplete_video_status(video_id).watched_ratio
      elsif self.incomplete_video_status(video_id)&.not_valid? || self.complete_video_status(video_id)&.not_valid?
        0.0
      end
    elsif current_system_admin
      if self.incomplete_video_status(video_id)
        self.incomplete_video_status(video_id).watched_ratio
      elsif self.incomplete_video_status(video_id).not_valid?
        0.0
      end
    end
  end

  def incomplete_video_status_hidden_button(video_id)
    if current_user&.owner?
      if self.not_zero_video_status(video_id)&.valid_true?
        link_to '視聴状況の削除', video_status_hidden_path(self.not_zero_video_status(video_id), video_id: video_id), class: 'btn btn-md btn-danger'
      else
        '未視聴'
      end
    elsif current_system_admin
      if self.not_zero_video_status(video_id)&.valid_true?
        link_to '視聴状況の削除', video_status_hidden_path(self.not_zero_video_status(video_id), video_id: video_id), class: 'btn btn-md btn-danger'
      elsif self.not_zero_video_status(video_id)&.not_valid?
        'オーナー削除済み'
      else
        '未視聴'
      end
    end
  end
end
