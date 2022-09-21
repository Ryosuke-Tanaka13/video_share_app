class Organizations::UnsubscribesController < OrganizationsController
  before_action :ensure_logged_in
  before_action :ensure_owner_of_set_organization
  before_action :set_organization
  layout 'organizations_auth'

  def show; end

  def update
    @organization.update(is_valid: false)
    User.includes([:organization]).update(is_valid: false)
    reset_session
    flash[:notice] = '退会処理が完了しました。'
    redirect_to root_path
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end
end
