class OrganizationsController < ApplicationController
  before_action :logged_in_account, except: %i[new create]
  before_action :logged_in_system_admin, only: %i[index destroy]
  before_action :admin_or_correct_owner, only: %i[show]
  before_action :correct_owner, only: %i[edit update]
  before_action :set_organization, except: %i[index new create]
  layout 'organizations_auth'

  def index
    @organizations = Organization.all
    render :layout => 'system_admins'
  end

  def new 
    @organization = Organization.new
    @user = User.new
  end

  def create
    ActiveRecord::Base.transaction do
    @user = User.new(user_params)
    form = Organizations::Form.new(params_permitted)
    @organization = Organization.build(form.params)
      if @organization.save!
        User.last.update(role: 1)
        flash[:success] = '送られてくるメールの認証URLからアカウントの認証をしてください。'
        redirect_to new_user_session_path
      else
        render :new
      end
    rescue ActiveRecord::RecordInvalid
      flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
      render :new
    end
  end

  def show
    render :layout => 'users' if current_user
    render :layout => 'system_admins' if current_system_admin
  end

  def edit
    render :layout => 'users' if current_user
    render :layout => 'system_admins' if current_system_admin
  end

  def update
    if @organization.update(organization_params)
      flash[:success] = '更新しました'
      redirect_to organization_url
    else
      render 'edit', :layout => 'users' if current_user
      render 'edit',  :layout => 'system_admins' if current_system_admin
    end
  end

  def destroy
    @organization.destroy!
    flash[:danger] = "#{@organization.name}のユーザー情報を削除しました"
    redirect_to organization_url
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :email)
  end

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def params_permitted
    params.require(:organization).permit(:name, :email, users: [:name, :email, :password, :password_confirmation])
  end

  def user_params
    params.require(:organization).permit(users: [:name, :email, :password, :password_confirmation])[:users]
  end

end


