# frozen_string_literal: true

module VideoDecorator
  def hidden_button
    if self.valid_true?
      link_to '削除', videos_hidden_path(self), class: 'btn btn-danger' if system_admin_signed_in? || current_user&.role == 'owner'
    else
      'オーナー削除済み'
    end
  end

  def notice_expire
    if (self.open_period&.<=Time.now) && self.nonpublic?
      tag.span style: ['color: red; border: dotted'] do
        '非公開中'
      end
    end
  end

  def selected_before_range
    return ['限定公開', 1] if self.range
  end

  def selected_before_comment_public
    return ['非公開', 1] if self.comment_public
  end

  def selected_before_login_set
    return ['ログイン必要', 1] if self.login_set
  end

  def selected_before_popup_before_video
    return ['動画視聴開始時ポップアップ非表示', 1] if self.popup_before_video
  end

  def selected_before_popup_after_video
    return ['動画視聴終了時ポップアップ非表示', 1] if self.popup_after_video
  end

  def ensure_owner?(current_user)
    return true if current_user.role == 'owner'

    false
  end
end
