class Viewers::UnsubscribesController < ViewersController
  before_action :ensure_logged_in
  before_action :ensure_viewer_exists
  before_action :ensure_admin_or_correct_viewer
  before_action :set_viewer
  layout 'viewers_auth'

  def show; end

  def update
    @viewer.update(is_valid: false)
    if current_user&.role == 'owner'
      flash[:notice] = "#{@viewer.name}のユーザー情報を削除しました"
      redirect_to viewers_url(organization_id: current_user.organization_id)
    elsif current_system_admin
      flash[:notice] = '退会処理が完了しました。'
      redirect_to viewer_url(params[:id])
    else # 本人の場合、セッションの解除
      reset_session
      flash[:notice] = '退会処理が完了しました。'
      redirect_to root_url
    end
  end

  private

  def set_viewer
    @viewer = Viewer.find(params[:id])
  end
end
