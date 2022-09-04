class Users::UnsubscribesController < ApplicationController
  before_action :set_user
  layout 'users_auth'
  
    def show
    end
  
    def update
      @user.update(is_valid: false)
      reset_session
      redirect_to root_path
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  
  end
  