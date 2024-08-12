class GroupsController < ApplicationController
  layout 'groups', only: %i[index show new edit update create destroy remove_viewer]
  before_action :ensure_logged_in
  before_action :ensure_admin_or_user
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
    organization_id = params[:organization_id] || current_user.organization_id
    @viewers = Viewer.for_current_user(current_user, organization_id)
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
    organization_id = params[:organization_id] || current_user&.organization_id
    if organization_id.nil?
      flash[:error] = '組織IDが見つかりません'
      redirect_back(fallback_location: root_path) and return
    end

    if current_system_admin?
      @viewers = Viewer.for_system_admin(organization_id)
    else
      @viewers = Viewer.for_current_user(current_user, organization_id)
    end
  end

  def update
    if @group.update(group_params)
      flash[:success] = '視聴グループを編集しました。'
      redirect_to groups_path(organization_id: @group.organization_id)
    else
      flash[:danger] = '視聴グループ名を入力してください'
      redirect_to edit_group_path(@group.uuid, organization_id: @group.organization_id)
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path, notice: 'グループを削除しました。'
  end

  def remove_viewer
    viewer = Viewer.find(params[:viewer_id])
    @group.viewers.delete(viewer)
    redirect_to groups_path
  end

  private

  def group_params
    params.require(:group).permit(:name, viewer_ids: [])
  end

  def set_group
    @group = Group.find_by(uuid: params[:uuid])
  end

  def check_viewer
    if !current_system_admin? && @group.organization_id != current_user.organization_id
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end

  def check_permission
    unless current_user&.role == 'owner' || current_system_admin?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end
end
