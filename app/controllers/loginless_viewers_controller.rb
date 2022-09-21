class LoginlessViewersController < ApplicationController
  layout 'organizations'

  before_action :ensure_logged_in, except: %i[create]
  before_action :ensure_admin, only: %i[destroy]
  before_action :ensure_admin_or_user, only: %i[index]
  before_action :ensure_admin_or_owner_in_same_organization_as_set_loginless_viewer, only: %i[show]
  before_action :set_loginless_viewer, except: %i[index create]

  def index
    @loginless_viewers = LoginlessViewer.all
  end

  def new
    @loginless_viewer = LoginlessViewer.new
  end

  def create
    @loginless_viewer = LoginlessViewer.new(loginless_viewer_params)
    if @loginless_viewer.save
      flash[:success] = "#{@loginless_viewer.name}の作成に成功しました"
      redirect_to loginless_viewers_url
    else
      render :new
    end
  end

  def show; end

  def destroy
    @loginless_viewer.destroy!
    flash[:danger] = "#{@loginless_viewer.name}のユーザー情報を削除しました"
    redirect_to loginless_viewers_url
  end

  private

  def loginless_viewer_params
    params.require(:loginless_viewer).permit(:name, :email)
  end

  def set_loginless_viewer
    @loginless_viewer = LoginlessViewer.find(params[:id])
  end

  # set_loginless_viewerと同組織オーナー　のみ許可
  def owner_in_same_organization_as_set_loginless_viewer
    if !owner_in_same_organization_as_set_loginless_viewer?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end

  # システム管理者　set_loginless_viewerと同組織オーナー　のみ許可
  def ensure_admin_or_owner_in_same_organization_as_set_loginless_viewer
    if !current_system_admin? && !owner_in_same_organization_as_set_loginless_viewer?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end
end
