class LoginlessViewersController < ApplicationController
  before_action :logged_in_system_admin, only: %i[destroy]
  before_action :admin_or_user, only: %i[index show]
  before_action :set_loginless_viewer, except: %i[index new create]

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

  def show
  end

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
end
