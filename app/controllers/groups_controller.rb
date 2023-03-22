class GroupsController < ApplicationController
  def index
    @groups = Group.all
  end

  def show
    @group = Group.find(params[:id])
  end

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

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    if @group.update(group_params)
      redirect_to groups_path
    else
      render 'edit'
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    redirect_to groups_path, notice: "グループを削除しました。"
  end

  def remove_viewer
    group = Group.find(params[:id])
    viewer = Viewer.find(params[:viewer_id])
    group.viewers.delete(viewer)

    redirect_to groups_path
  end

  private

  def group_params
    params.require(:group).permit(:name, viewer_ids: [])
  end
end
