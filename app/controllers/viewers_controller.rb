class ViewersController < ApplicationController
  before_action :ensure_logged_in
  before_action :ensure_admin, only: %i[destroy]
  before_action :ensure_admin_or_user, only: %i[index]
  before_action :ensure_viewer_exists, only: %i[show edit update]
  before_action :ensure_admin_or_owner_in_same_organization_as_set_viewer_or_correct_viewer, only: %i[show edit update]
  before_action :set_viewer, except: %i[index]

  def index
    if params[:organization_id].nil? && current_system_admin
      @viewers = Viewer.all
    elsif current_system_admin
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
    organization_id = Organization.includes(:organization_viewers).viewer_existence_confirmation(params[:id]).id
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

  # システム管理者　set_viewerと同組織オーナー　視聴者本人　のみ許可
  def ensure_admin_or_owner_in_same_organization_as_set_viewer_or_correct_viewer
    if !current_system_admin? && !owner_in_same_organization_as_set_viewer? && !correct_viewer?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end

  # システム管理者　視聴者本人　のみ許可
  def ensure_admin_or_correct_viewer
    if !current_system_admin? && !correct_viewer?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end

  # 視聴者のアカウントが存在しているか確認、退会した視聴者はシステム管理者のみ許可
  def ensure_viewer_exists
    viewer = Viewer.find_by(id: params[:id])
    if viewer.nil? || (viewer.is_valid == false && !current_system_admin?)
      flash[:danger] = '存在しないアカウントです。'
      redirect_back(fallback_location: root_url)
    end
  end
end
