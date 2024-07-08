# frozen_string_literal: true

class ApplicationController < ActionController::Base
  add_flash_types :success, :info, :warning, :danger
  before_action :configure_permitted_parameters, if: :devise_controller?

  # ログイン後の遷移先
  def after_sign_in_path_for(resource)
    case resource
    when Viewer
      viewer_path(action: 'show', id: current_viewer.id)
    when SystemAdmin
      organizations_path
    when User
      organization_folders_path(organization_id: current_user.organization_id)
    end
  end

  def configure_permitted_parameters
    added_attrs = %i[email name password password_confirmation]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
  end

  # アカウントのどれでもログインしていれば、trueを返す
  def logged_in?
    !current_system_admin.nil? || !current_user.nil? || !current_viewer.nil?
  end

  # システム管理者がログインしていれば、trueを返す
  def current_system_admin?
    !current_system_admin.nil?
  end

  # システム管理者がログインしていれば、trueを返す
  def current_user?
    !current_user.nil?
  end

  # システム管理者がログインしていれば、trueを返す
  def current_viewer?
    !current_viewer.nil?
  end

  # 投稿者本人であればtrueを返す
  def correct_user?
    current_user == User.find(params[:id])
  end

  # 視聴者本人であればtrueを返す
  def correct_viewer?
    current_viewer == Viewer.find(params[:id])
  end

  # set_organizationと同組織投稿者の場合trueを返す
  def user_of_set_organization?
    current_user&.organization_id == params[:id].to_i
  end

  # set_userと同組織投稿者であればtrueを返す
  def user_in_same_organization_as_set_user?
    current_user&.organization_id == User.find(params[:id]).organization_id
  end

  # set_userと同組織オーナーであればtrueを返す
  def owner_in_same_organization_as_set_user?
    current_user&.role == 'owner' && user_in_same_organization_as_set_user?
  end

  # set_viewerと同組織投稿者であればtrueを返す
  def user_in_same_organization_as_set_viewer?
    !OrganizationViewer.where(viewer_id: params[:id]).find_by(organization_id: current_user&.organization_id).nil?
  end

  # set_viewerと同組織オーナーであればtrueを返す
  def owner_in_same_organization_as_set_viewer?
    current_user&.role == 'owner' && user_in_same_organization_as_set_viewer?
  end

  # ログイン中　のみ許可
  def ensure_logged_in
    unless logged_in?
      flash[:danger] = 'ログインしてください。'
      redirect_to root_url
    end
  end

  # システム管理者　のみ許可
  def ensure_admin
    unless current_system_admin?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end

  # オーナー　のみ許可
  def ensure_owner
    if current_user&.role != 'owner'
      flash[:danger] = '権限がありません'
      redirect_to users_url
    end
  end

  # システム管理者　投稿者　のみ許可
  def ensure_admin_or_user
    if !current_system_admin? && !current_user?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end

  def current_organization
    @current_organization = Organization.find(current_user.organization_id)
  end
  helper_method :current_organization
end
