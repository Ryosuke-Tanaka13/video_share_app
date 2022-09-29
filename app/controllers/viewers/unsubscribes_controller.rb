class Viewers::UnsubscribesController < ViewersController
  before_action :ensure_logged_in
  before_action :not_exist
  before_action :ensure_admin_or_owner_in_same_organization_as_set_viewer_or_correct_viewer
  before_action :set_viewer
  layout 'viewers_auth'

  def show; end

  def update
    @viewer.update(is_valid: false)
    if current_user&.role == 'owner'
      flash[:notice] = "#{@viewer.name}のユーザー情報を削除しました"
      redirect_to viewers_path(organization_id: current_user.organization_id)
    elsif current_system_admin
      flash[:notice] = '退会処理が完了しました。'
      redirect_to viewer_path(params[:id])
    else # 本人の場合、セッションの解除
      reset_session
      flash[:notice] = '退会処理が完了しました。'
      redirect_to root_path
    end
  end

  private

  def set_viewer
    @viewer = Viewer.find(params[:id])
  end
end
