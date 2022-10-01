class Organizations::UnsubscribesController < OrganizationsController
  before_action :ensure_logged_in
  before_action :ensure_admin_or_owner_of_set_organization
  before_action :set_organization
  layout 'organizations_auth'

  def show; end

  def update
    if Organization.bulk_update(params[:id])
      if current_system_admin
        flash[:notice] = '退会処理が完了しました。'
        redirect_to organizations_path
      else
        reset_session
        flash[:notice] = '退会処理が完了しました。'
        redirect_to root_path
      end
    else
      render :show
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end
end
