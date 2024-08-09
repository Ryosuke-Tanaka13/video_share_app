# frozen_string_literal: true

module Viewers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    layout 'viewers_auth'

    def google_oauth2
      callback_for(:google)
    end

    def callback_for(provider)
      # 先ほどviewer.rbで記述したメソッド(from_omniauth)をここで使っています
      # 'request.env["omniauth.auth"]'この中に、googoleアカウントから取得したメールアドレスや、名前と言ったデータが含まれています
      @viewer = Viewer.from_omniauth(request.env['omniauth.auth'])
      sign_in_and_redirect @viewer, event: :authentication
      set_flash_message(:notice, :success, kind: provider.to_s.capitalize) if is_navigational_format?
    end

    def failure
      redirect_to root_path
    end

    # You should configure your model like this:
    # devise :omniauthable, omniauth_providers: [:twitter]

    # You should also create an action method in this controller like this:
    # def twitter
    # end

    # More info at:
    # https://github.com/heartcombo/devise#omniauth

    # GET|POST /resource/auth/twitter
    # def passthru
    #   super
    # end

    # GET|POST /users/auth/twitter/callback
    # def failure
    #   super
    # end

    # protected

    # The path used when OmniAuth fails
    # def after_omniauth_failure_path_for(scope)
    #   super(scope)
    # end
  end
end
