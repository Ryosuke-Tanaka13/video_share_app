class UsersController < ApplicationController
  before_action :logged_in_account
  before_action :correct, only: %i[destroy]
  before_action :admin_or_user, only: %i[index]
  before_action :admin_or_correct_owner, only: %i[destroy]
  before_action :admin_or_owner_or_correct_user, only: %i[show]
  before_action :owner_or_correct_user, only: %i[edit update]
  before_action :set_user, except: %i[index new create]

  def index
    if current_system_admin
      if params[:organization_id].nil?
        @users = User.all
      else
        @users = User.where(organization_id: params[:organization_id])
        @organization = Organization.find(params[:organization_id])
      end
    else
      @users = User.current_owner_has(current_user).unsubscribe
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.update(organization_id: current_user.organization_id)
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
    if current_system_admin
      @user.destroy!
    else
      @user.update(is_valid: false)
    end
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
