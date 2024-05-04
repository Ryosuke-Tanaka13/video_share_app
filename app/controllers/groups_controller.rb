class GroupsController < ApplicationController
  layout 'groups', only: %i[index show new edit update create destroy remove_viewer]
  before_action :ensure_logged_in
  before_action :ensure_admin_or_user
  before_action :not_exist, only: %i[show edit update]
  before_action :set_group, only: %i[show edit update destroy remove_viewer]
  before_action :check_viewer, only: %i[show edit update destroy remove_viewer]
  before_action :check_permission, only: [:destroy]

  def index
    if current_user
      @groups = Group.where(organization_id: current_user.organization_id)
      @select_organization = current_user.organization
    elsif current_system_admin
      @groups = Group.where(organization_id: params[:organization_id])
      @select_organization = Organization.find(params[:organization_id]) if params[:organization_id].present?
    end
  end

  def show; end

  def new
    @group = Group.new
    @viewers = Viewer.joins(:organization_viewers).where(organization_viewers: { organization_id: current_user.organization_id })
  end

  def create
    @group = Group.new(group_params)
    @group.organization_id = current_user.organization_id
    if @group.save
      redirect_to groups_path
    else
      render 'new'
    end
  end

  def edit
    if current_system_admin
      @viewers = Viewer.joins(:organization_viewers).where(organization_viewers: { organization_id: params[:organization_id] })
    else
      @viewers = Viewer.joins(:organization_viewers).where(organization_viewers: { organization_id: current_user.organization_id })
    end
  end

  def update
    if @group.update(group_params)
      redirect_to groups_path(organization_id: @group.organization_id)
    else
      @viewers = Viewer.joins(:organization_viewers).where(organization_viewers: { organization_id: current_user.organization_id })
      render 'edit'
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path, notice: 'グループを削除しました。'
  end

  def remove_viewer
    viewer = Viewer.find(params[:viewer_id])
    group.viewers.delete(viewer)

    redirect_to groups_path
  end

  private

  def group_params
    params.require(:group).permit(:name, viewer_ids: [])
  end

  def set_group
    @group = Group.find_by(uuid: params[:uuid])
  end

  # set_viewerが退会済であるページは、システム管理者のみ許可
  def not_exist
    if current_user && Viewer.find_by(id: current_user.id)&.is_valid == false && !current_system_admin?
      flash[:danger] = '存在しないアカウントです。'
      redirect_back(fallback_location: root_url)
    end
  end

  def check_viewer
    if !current_system_admin?
      unless @group.organization_id == current_user.organization_id
        flash[:danger] = '権限がありません。'
        redirect_back(fallback_location: root_url)
      end
    end
  end

  def check_permission
    unless current_user&.role == 'owner' || current_system_admin?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end
end
