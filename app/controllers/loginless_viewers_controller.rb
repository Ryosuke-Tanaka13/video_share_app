class LoginlessViewersController < ApplicationController
  layout 'organizations'

  before_action :ensure_logged_in, except: %i[create]
  before_action :ensure_admin, only: %i[destroy]
  before_action :ensure_admin_or_user, only: %i[index]
  before_action :ensure_admin_or_owner_in_same_organization_as_set_loginless_viewer, only: %i[show]
  before_action :set_loginless_viewer, except: %i[index create]

  def index
    # system_adminが/loginless_viewersへ直接アクセスするとエラーになる仕様
    if current_system_admin
      @loginless_viewers = LoginlessViewer.loginless_viewer_has(params[:organization_id])
      # 組織名を表示させるためのインスタンス変数
      @organization = Organization.find(params[:organization_id])
    else
      @loginless_viewers = LoginlessViewer.current_owner_has(current_user).subscribed
    end
  end

  # ポップアップでの作成の為、new なし

  def create
    @loginless_viewer = LoginlessViewer.new(loginless_viewer_params)
    if @loginless_viewer.save
      flash[:success] = "#{@loginless_viewer.name}の作成に成功しました"
      redirect_to root_path
    else
      redirect_to root_path
    end
  end

  def show;
    # viewの所属組織名を表示させるために記載
    @organizations = Organization.loginless_viewer_has(params[:id])
  end

  def destroy
    @loginless_viewer.destroy!
    flash[:danger] = "#{@loginless_viewer.name}のユーザー情報を削除しました"
    redirect_to organizations_url
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
