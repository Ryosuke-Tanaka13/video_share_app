class Organizations::FoldersController < ApplicationController
  layout 'organizations'

  before_action :ensure_owner
  before_action :set_folder, only: %i[show update destroy]

  def index
    @folders = Folder.current_owner_has(current_user)
  end

  def show; end

  def new
    @folder = Folder.new
  end

  def create
    @folder = Folder.new(folder_params)
    if @folder.create(current_user)
      if URI(request.referer.to_s).path == folders_path 
        redirect_to folders_path, flash: { success: 'フォルダを作成しました！' }
      else
        redirect_to new_video_path, flash: { success: 'フォルダを作成しました！' }
      end
    else
      render 'new'
    end
  end

  def update
    if @folder.owner_has?(current_user) && @folder.update(folder_params)
      redirect_to folders_path
    else
      redirect_to folders_path, flash: { danger: 'フォルダ名が空欄、もしくは同じフォルダ名があります。' }
    end
  end

  def destroy
    if @folder.owner_has?(current_user) && @folder.destroy
      redirect_to folders_path, flash: { danger: 'フォルダを削除しました' }
    else
      redirect_to folders_path
    end
  end

  private

  def folder_params
    params.require(:folder).permit(:name)
  end

  def set_folder
    @folder = Folder.find(params[:id])
  end

  def ensure_owner
    if current_user.role != 'owner'
      flash[:danger] = '権限がありません'
      redirect_to users_path
    end
  end
end
