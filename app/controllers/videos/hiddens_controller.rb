class Videos::HiddensController < VideosController
  before_action :ensure_logged_in
  before_action :set_video
  before_action :ensure_admin_or_user
  before_action :ensure_admin_or_owner
  before_action :ensure_my_organization

  def confirm; end

  def withdraw
    if @video.update(is_valid: false)
      flash[:success] = '削除しました'
      redirect_to videos_url(organization_id: @video.organization.id)
    else
      render :show
    end
  end

  private

  # 共通メソッド(organization::foldersコントローラにも記載)
  def ensure_admin_or_owner
    if current_user.present? && current_user.role != 'owner'
      redirect_to users_url, flash: { danger: '権限がありません' }
    end
  end
end
