class Organizations::AdmissionsController < ApplicationController
  before_action :ensure_logged_in
  before_action :ensure_logged_in_viewer, only: %i[show update]
  before_action :ensure_non_enrolled, only: %i[show update]
  before_action :ensure_admin_or_owner_of_set_organization_or_correct_viewer, only: %i[destroy]
  before_action :ensure_admissioned_viewer, only: %i[destroy]
  before_action :set_organization
  layout 'organizations_auth'

  def show; end

  def update
    viewer = Viewer.find(current_viewer.id)
    @organization.viewers << viewer
    redirect_to viewer_url(current_viewer), notice: "#{@organization.name}へ加入しました。"
  end

  def destroy
    OrganizationViewer.find_by(organization_id: params[:id], viewer_id: params[:viewer_id]).destroy
    if current_viewer || current_system_admin
      redirect_to viewer_url(params[:viewer_id]), notice: "#{@organization.name}を脱退しました。"
    else
      redirect_to viewers_url(@organization), notice: "#{Viewer.find(params[:viewer_id]).name}は#{@organization.name}を脱退しました。"
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  # ログイン済視聴者　のみ許可
  def ensure_logged_in_viewer
    unless current_viewer?
      flash[:danger] = '視聴者でログインしてください。'
      redirect_back(fallback_location: root_url)
    end
  end

  # set_organizationへ未所属の視聴者　のみ許可
  def ensure_non_enrolled
    if OrganizationViewer.find_by(organization_id: params[:id], viewer_id: current_viewer.id)
      flash[:danger] = '既に加入されています'
      redirect_back(fallback_location: root_url)
    end
  end

  # set_organizationへ所属済の視聴者　のみ許可
  def ensure_admissioned_viewer
    if OrganizationViewer.find_by(organization_id: params[:id], viewer_id: current_viewer&.id).nil? && current_viewer
      flash[:danger] = '権限がありません'
      redirect_back(fallback_location: root_url)
    end
  end

  # システム管理者　set_organizationのオーナー　視聴者本人　のみ許可
  def ensure_admin_or_owner_of_set_organization_or_correct_viewer
    if !current_system_admin? && (current_user&.role != 'owner' || !user_of_set_organization?) && params[:viewer_id].to_i != current_viewer&.id
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end
end
