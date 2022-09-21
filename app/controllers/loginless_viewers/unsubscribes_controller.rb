class LoginlessViewers::UnsubscribesController < LoginlessViewersController
  before_action :ensure_logged_in
  before_action :owner_in_same_organization_as_set_loginless_viewer
  before_action :set_viewer

  def update
    @loginless_viewer.update(is_valid: false)
    flash[:notice] = "#{@loginless_viewer.name}のユーザー情報を削除しました"
    redirect_to loginless_viewers_url
  end

  private

  def set_viewer
    @viewer_loginless = LoginlessViewer.find(params[:id])
  end
end
