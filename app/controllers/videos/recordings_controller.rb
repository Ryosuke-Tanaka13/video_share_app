class Videos::RecordingsController < ApplicationController
  before_action :ensure_current_user
  before_action :set_user_id
  layout 'recordings'

  private

  def set_user_id
    @user = current_user
  end

  # ログイン中のuserのみ許可
  def ensure_current_user
    unless current_user?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end
end
