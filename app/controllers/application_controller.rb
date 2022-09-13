# frozen_string_literal: true

class ApplicationController < ActionController::Base
  add_flash_types :success, :info, :warning, :danger
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    case resource
    when Viewer
      viewer_path(action: 'show', id: current_viewer.id)
    when SystemAdmin
      organizations_path
    when User
      users_path
    end
  end

  def configure_permitted_parameters
    added_attrs = %i[email name password password_confirmation]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
  end

  # ログインしていない時、falseを返す
  def logged_in?
    !current_system_admin.nil? || !current_user.nil? || !current_viewer.nil?
  end

  # falseの場合アクセス禁止
  def logged_in_account
    unless logged_in?
      flash[:danger] = 'ログインしてください。'
      redirect_to root_url
    end
  end

  # システム管理者がログインしていない場合アクセス禁止
  def logged_in_system_admin
    if current_system_admin.nil?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end

  # 本人以外
  def other_the_person
    if (current_system_admin&.id == params[:id].to_i) || (current_user&.id == params[:id].to_i) || (current_viewer&.id == params[:id].to_i)
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end

  # 同組織オーナー　のみ
  def same_org_owner
    unless current_user&.role == 'owner' && current_user.organization_id == params[:id].to_i
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end

  # 視聴者本人　のみ
  def correct_viewer
    unless current_viewer&.id == params[:id].to_i
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end

  # システム管理者　投稿者　のみ
  def admin_or_user
    unless !current_system_admin.nil? || !current_user.nil?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end

  # 同組織オーナー　投稿者本人　のみ
  def same_org_owner_or_correct_user
    @user = User.find(params[:id]) if @user.blank?
    @organization = Organization.find(@user.organization_id) if @organization.blank?
    unless (current_user&.role == 'owner' && current_user.organization_id == @organization.id) || current_user == @user
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end

  # システム管理者　同組織オーナー　のみ
  def admin_or_same_org_owner
    @user = User.find(params[:id]) if @user.blank?
    @organization = Organization.find(@user.organization_id) if @organization.blank?
    unless !current_system_admin.nil? ||
           (current_user&.role == 'owner' && current_user.organization_id == @organization.id)
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end

  # システム管理者　同組織オーナー　投稿者本人 のみ
  def admin_or_same_org_owner_or_correct_user
    @user = User.find(params[:id]) if @user.blank?
    @organization = Organization.find(@user.organization_id) if @organization.blank?
    unless !current_system_admin.nil? || (current_user&.role == 'owner' && current_user.organization_id == @organization.id) || current_user == @user
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end

  # システム管理者　同組織投稿者　のみ
  def admin_or_same_org_user
    @organization = Organization.find(params[:id]) if @organization.blank?
    unless !current_system_admin.nil? || current_user&.organization_id == @organization.id
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end

  # システム管理者　投稿者　視聴者本人　のみ
  def admin_or_user_or_correct_viewer
    @viewer = Viewer.find(params[:id]) if @viewer.blank?
    unless  !current_system_admin.nil? || !current_user.nil? || current_viewer == @viewer
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_path)
    end
  end
end
