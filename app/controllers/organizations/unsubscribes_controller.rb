class Organizations::UnsubscribesController < ApplicationController
  before_action :correct_owner
  before_action :set_organization
  layout 'organizations_auth'
  
  def show
  end

  def update
    @organization.update(is_valid: false)
    User.where(organization_id: params[:id]).update(is_valid: false)
    reset_session
    flash[:notice] = "退会処理が完了しました。"
    redirect_to root_path
  end

    private

    def set_organization
      @organization = Organization.find(params[:id])
    end
  
  end
  