# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    layout 'users_auth'

    before_action :reject_inactive_user, only: [:create]
    before_action :ensure_other_account_logged_out, only: %i[new create]
    # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /resource/sign_in
    # def create
    #   super
    # end

    # DELETE /resource/sign_out
    # def destroy
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
    def reject_inactive_user
      @user = User.find_by(email: params[:user][:email], is_valid: true)
      if @user && (@user.valid_password?(params[:user][:password]) && !@user.is_valid)
        flash[:notice] = 'Eメールまたはパスワードが違います。'
        redirect_to new_user_session_url
      end
    end

    # 他アカウントがログアウト中　のみ許可
    def ensure_other_account_logged_out
      if current_system_admin? || current_viewer?
        flash[:danger] = 'ログアウトしてください。'
        redirect_back(fallback_location: root_url)
      end
    end
  end
end
