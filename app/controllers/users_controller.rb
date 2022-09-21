class UsersController < ApplicationController
  before_action :ensure_logged_in
  before_action :ensure_admin, only: %i[destroy]
  before_action :ensure_owner, only: %i[new create]
  before_action :ensure_admin_or_user, only: %i[index]
  before_action :ensure_admin_or_owner_in_same_organization_as_set_user_or_correct_user, only: %i[show]
  before_action :ensure_owner_in_same_organization_as_set_user_or_correct_user, only: %i[edit update]
  before_action :set_user, except: %i[index new create]

  def index
    # system_adminが/usersへ直接アクセスするとエラーになる仕様
    if current_system_admin
      @users = User.user_has(params[:organization_id])
      # 組織名を表示させるためのインスタンス変数
      @organization = Organization.find(params[:organization_id])
    else
      @users = User.current_owner_has(current_user).subscribed
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_create_params)
    if @user.save
      flash[:success] = "#{@user.name}の作成に成功しました"
      redirect_to users_url
    else
      render :new
    end
  end

  def show
    # viewの所属組織名を表示させるために記載
    @organization = Organization.find(@user.organization_id)
  end

  def edit; end

  def update
    if @user.update(user_update_params)
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

  # スタッフ作成時、オーナーと同組織にし、roleをstaffへ変更
  def user_create_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation).merge(organization_id: current_user.organization_id, role: 'staff')
  end

  def user_update_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def set_user
    @user = User.find(params[:id])
  end

  # set_userと同組織オーナー　投稿者本人　のみ許可
  def ensure_owner_in_same_organization_as_set_user_or_correct_user
    if !owner_in_same_organization_as_set_user? && !correct_user?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end

  # システム管理者　set_userと同組織オーナー　投稿者本人 のみ許可
  def ensure_admin_or_owner_in_same_organization_as_set_user_or_correct_user
    if current_system_admin.nil? && !owner_in_same_organization_as_set_user? && !correct_user?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end
end
