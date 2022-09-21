class ViewersController < ApplicationController
  before_action :ensure_logged_in
  before_action :ensure_admin, only: %i[destroy]
  before_action :ensure_admin_or_user, only: %i[index]
  before_action :ensure_correct_viewer, only: %i[edit update]
  before_action :ensure_admin_or_owner_in_same_organization_as_set_viewer_or_correct_viewer, only: %i[show]
  before_action :set_viewer, except: %i[index]

  def index
    # system_adminが/viewersへ直接アクセスするとエラーになる仕様
    if current_system_admin
      @viewers = Viewer.viewer_has(params[:organization_id])
      # 組織名を表示させるためのインスタンス変数
      @organization = Organization.find(params[:organization_id])
    else
      @viewers = Viewer.current_owner_has(current_user).subscribed
    end
  end

  # deviseのnewとcreateのみ使用可能

  def show
    # viewの所属組織名を表示させるために記載
    @organizations = Organization.viewer_has(params[:id])
  end

  def edit; end

  def update
    if @viewer.update(viewer_params)
      flash[:success] = '更新しました'
      redirect_to viewer_url
    else
      render 'edit'
    end
  end

  def destroy
    # viewrが削除される前にorganization_idを保存しておく
    organization_id = Organization.viewer_existence_confirmation(params[:id]).id
    @viewer.destroy!
    flash[:danger] = "#{@viewer.name}のユーザー情報を削除しました"
    redirect_to viewers_url(organization_id: organization_id)
  end

  private

  def viewer_params
    params.require(:viewer).permit(:name, :email)
  end

  def set_viewer
    @viewer = Viewer.find(params[:id])
  end

  # 視聴者本人　のみ許可
  def ensure_correct_viewer
    unless correct_viewer?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end

  # システム管理者　set_viewerと同組織オーナー　視聴者本人　のみ許可
  def ensure_admin_or_owner_in_same_organization_as_set_viewer_or_correct_viewer
    if !current_system_admin? && !owner_in_same_organization_as_set_viewer? && !correct_viewer?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end
end
