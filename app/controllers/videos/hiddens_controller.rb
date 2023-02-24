class Videos::HiddensController < VideosController
  before_action :ensure_logged_in
  before_action :ensure_admin_or_user
  before_action :ensure_admin_or_owner
  before_action :ensure_my_organization_set_video

  def confirm
    set_video
  end

  def withdraw
    set_video
    @video.assign_attributes(is_valid: false)
    @video.save!(validate: false)
    flash[:success] = '削除しました。'
    redirect_to videos_url(organization_id: @video.organization.id)
  end

  private

  # before_actionとして記載(organization::foldersコントローラでも定義)
  def ensure_admin_or_owner
    if current_user.present? && current_user.role != 'owner'
      redirect_to users_url, flash: { danger: '権限がありません。' }
    end
  end
end
