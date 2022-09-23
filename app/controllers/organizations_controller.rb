class OrganizationsController < ApplicationController
  before_action :ensure_logged_in, except: %i[new create]
  before_action :ensure_admin, only: %i[index destroy]
  before_action :ensure_admin_or_user_in_same_organization_as_set_organization, only: %i[show]
  before_action :ensure_owner_of_set_organization, only: %i[edit update]
  before_action :set_organization, except: %i[index new create]
  layout 'organizations_auth', only: %i[new create]

  def index
    @organizations = Organization.all
  end

  def new
    @organization = Organization.new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    form = Organizations::Form.new(params_permitted)
    @organization = Organization.build(form.params)
    if @organization.save
      flash[:success] = '送られてくるメールの認証URLからアカウントの認証をしてください。'
      redirect_to new_user_session_path
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @organization.update(organization_params)
      flash[:success] = '更新しました'
      redirect_to organization_url
    else
      render 'edit'
    end
  end

  def destroy
    @organization.destroy!
    flash[:danger] = "#{@organization.name}を削除しました"
    redirect_to organizations_url
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :email)
  end

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def params_permitted
    params.require(:organization).permit(:name, :email, users: %i[name email password password_confirmation])
  end

  def user_params
    params.require(:organization).permit(users: %i[name email password password_confirmation])[:users]
  end

  # set_organizationのオーナー　のみ許可
  def ensure_owner_of_set_organization
    if current_user&.role != 'owner' || !user_of_set_organization?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end

  # システム管理者　set_userと同組織投稿者　のみ許可
  def ensure_admin_or_user_in_same_organization_as_set_organization
    if current_system_admin.nil? && !user_of_set_organization?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end
end
