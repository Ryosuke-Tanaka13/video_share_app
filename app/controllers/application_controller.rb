# frozen_string_literal: true

class ApplicationController < ActionController::Base
  add_flash_types :success, :info, :warning, :danger
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    case resource
    when Viewer
      viewers_path
    when SystemAdmin
      system_admin_path(action: 'show', id: 1)
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

  # 現在ログインしているアカウントをセット
  def set_account
    if current_user.present?
      @account = current_user
    elsif current_viewer.preesent?
      @account = current_viewer
    end
  end
  
end
