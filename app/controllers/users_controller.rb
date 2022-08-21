class UsersController < ApplicationController
  before_action :set_user, except: %i[index new create]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "#{@user.name}の作成に成功しました"
      redirect_to users_url
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = '更新しました'
      redirect_to users_url
    else
      render 'edit'
    end
  end

  def destroy
    @user.destroy!
    flash[:danger] = "#{@user.name}のユーザー情報を削除しました"
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def set_user
    @user = User.find(params[:id])
  end
end
