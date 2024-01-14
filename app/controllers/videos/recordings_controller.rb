class Videos::RecordingsController < ApplicationController
  before_action :ensure_current_user
  layout 'recordings'

  private
  # ログイン中のuserのみ許可
  def ensure_current_user
    unless current_user?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end
end
