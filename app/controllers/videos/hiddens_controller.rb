class Videos::HiddensController < VideosController
  before_action :ensure_logged_in
  before_action :ensure_admin_or_owner
  before_action :ensure_my_organization_set_video

  def confirm
    @video = set_video
  end

  def withdraw
    @video = set_video
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
    if !current_system_admin? && (current_user&.role != 'owner')
      redirect_to users_url, flash: { danger: '権限がありません。' }
    end
  end
end
