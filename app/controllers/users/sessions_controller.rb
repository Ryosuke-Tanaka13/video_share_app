# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    layout 'users_auth'
    before_action :reject_inactive_user, only: [:create]
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
      @user = User.find_by(email: params[:user][:email])
      if @user
        if @user.valid_password?(params[:user][:password]) && !@user.is_valid
          flash[:notice] = "Eメールまたはパスワードが違います。"
          redirect_to new_user_session_path
        end
      end
    end
  end
end
