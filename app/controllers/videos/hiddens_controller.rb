class Videos::HiddensController < VideosController
  before_action :ensure_exist_set_video
  before_action :ensure_logged_in
  before_action :ensure_admin_or_user
  before_action :ensure_admin_or_owner

  def confirm
    set_video
  end

  def withdraw
    set_video
    if @video.update(is_valid: false)
      flash[:success] = '削除しました。'
      redirect_to videos_url(organization_id: @video.organization.id)
    else
      render :show
    end
  end

  private

  # before_actionとして記載(organization::foldersコントローラでも定義)
  def ensure_admin_or_owner
    if current_user.present? && current_user.role != 'owner'
      redirect_to users_url, flash: { danger: '権限がありません。' }
    end
  end
end
