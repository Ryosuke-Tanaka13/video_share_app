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

  def logged_in?
    !current_system_admin.nil? || !current_user.nil? || !current_viewer.nil?
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  def logged_in_account
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to root_url
    end
  end
  
  def logged_in_system_admin
    unless !current_system_admin.nil?
      flash[:danger] = "権限がありません。"
      redirect_back(fallback_location: root_path)
    end  
  end

  def correct_user
    unless current_user.id == params[:id].to_i
      flash[:danger] = "権限がありません。"
      redirect_back(fallback_location: root_path)
    end
  end

  def owner_or_correct_user
    @user = User.find(params[:id]) if @user.blank?
    unless current_user&.role == "owner" || current_user == @user
      flash[:danger] = "権限がありません。"
      redirect_back(fallback_location: root_path)
    end  
  end

  def admin_or_owner_or_correct_user
    @user = User.find(params[:id]) if @user.blank?
    unless !current_system_admin.nil? || current_user&.role == "owner" || current_user == @user
      flash[:danger] = "権限がありません。"
      redirect_back(fallback_location: root_path)
    end  
  end

  def admin_or_owner
    unless !current_system_admin.nil? || current_user&.role == "owner"
      flash[:danger] = "権限がありません。"
      redirect_back(fallback_location: root_path)
    end  
  end

  def admin_or_user
    unless !current_system_admin.nil? || !current_user.nil?
      flash[:danger] = "権限がありません。"
      redirect_back(fallback_location: root_path)
    end  
  end
  
  def admin_or_user_or_correct_viewer
    @viewer = Viewer.find(params[:id]) if @viewer.blank?
    unless  !current_system_admin.nil? || !current_user.nil? || current_viewer == @viewer
      flash[:danger] = "権限がありません。"
      redirect_back(fallback_location: root_path)
    end  
  end

  def admin_or_correct_owner
    unless !current_system_admin.nil? ||
           (current_user&.role == "owner" && current_user.organization_id == params[:id].to_i)
      flash[:danger] = "権限がありません。"
      redirect_back(fallback_location: root_path)
    end  
  end

  def correct_owner
    unless (current_user&.role == "owner" && current_user.organization_id == params[:id].to_i)
      flash[:danger] = "権限がありません。"
      redirect_back(fallback_location: root_path)
    end  
  end
end
