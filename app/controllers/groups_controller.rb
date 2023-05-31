class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy, :remove_viewer]

  def index
    @groups = Group.all
  end

  def show; end

  def new
    @group = Group.new
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

  def edit; end

  def update
    if @group.update(group_params)
      redirect_to groups_path
    else
      render 'edit'
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path, notice: "グループを削除しました。"
  end

  def remove_viewer
    viewer = Viewer.find(params[:viewer_id])
    group.viewers.delete(viewer)

    redirect_to groups_path
  end

  private
  
  def set_group
    @group = Group.find_by(uuid: params[:uuid])
  end

  def group_params
    params.require(:group).permit(:name, viewer_ids: [])
  end
end
