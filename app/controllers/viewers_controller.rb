class ViewersController < ApplicationController
  before_action :logged_in_account
  before_action :logged_in_system_admin, only: %i[destroy]
  before_action :admin_or_user, only: %i[index]
  before_action :admin_or_user_or_correct_viewer, only: %i[show]
  before_action :correct_viewer, only: %i[edit update]
  before_action :set_viewer, except: %i[index new create]

  def index
    @viewers = Viewer.all
    render :layout => 'users' if current_user
    render :layout => 'system_admins' if current_system_admin
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

  def show
    render :layout => 'viewers' if current_viewer
    render :layout => 'users' if current_user
    render :layout => 'system_admins' if current_system_admin
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
end
