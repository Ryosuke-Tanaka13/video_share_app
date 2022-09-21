class ViewersController < ApplicationController
  before_action :ensure_logged_in
  before_action :ensure_admin, only: %i[destroy]
  before_action :ensure_admin_or_user, only: %i[index]
  before_action :ensure_correct_viewer, only: %i[edit update]
  before_action :ensure_admin_or_owner_in_same_organization_as_set_viewer_or_correct_viewer, only: %i[show]
  before_action :set_viewer, except: %i[index]

  def index
    @viewers = Viewer.all
  end

  def new
    @viewer = Viewer.new
  end

  def create
    @viewer = Viewer.new(viewer_params)
    if @viewer.save
      flash[:success] = "#{@viewer.name}の作成に成功しました"
      redirect_to viewers_url
    else
      render :new
    end
  end

  def show; end

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
    @viewer.destroy!
    flash[:danger] = "#{@viewer.name}のユーザー情報を削除しました"
    redirect_to viewers_url
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
    if !correct_viewer?
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
