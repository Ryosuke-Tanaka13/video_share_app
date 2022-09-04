class Organizations::FoldersController < ApplicationController
  layout 'organizations'

  before_action :access_right
  before_action :ensure_system_admin_or_owner, only: %i[destroy]
  before_action :ensure_user, only: %i[create update]
  before_action :set_folder, only: %i[show update destroy]
  

  def index
    @organization = Organization.find_by(id: params[:organization_id])
    @folders = @organization.folders
  end

  def show; end

  def new
    @folder = Folder.new
  end

  def create
    @folder = Folder.new(folder_params)
    if @folder.create(current_user)
      redirect_to organization_folders_path, flash: { success: 'フォルダを作成しました！' }
    else
      render 'new'
    end
  end

  def update
    if @folder.owner_has?(current_user) && @folder.update(folder_params)
      redirect_to organization_folders_path
    else
      redirect_to organization_folders_path, flash: { danger: 'フォルダ名が空欄、もしくは同じフォルダ名があります。' }
    end
  end

  def destroy
    if (current_system_admin.present? || @folder.owner_has?(current_user)) && @folder.destroy
      redirect_to organization_folders_path, flash: { danger: 'フォルダを削除しました' }
    else
      redirect_to organization_folders_path
    end
  end

  private

  def folder_params
    params.require(:folder).permit(:name)
  end

  def set_folder
    @folder = Folder.find(params[:id])
  end

  #system_admin、組織管理者、動画投稿者のみ許可
  def access_right
    if current_system_admin.nil? && current_user.nil?
      flash[:danger] = '権限がありません'
      redirect_to root_path
    end
  end

  #system_adminかownerのみ許可
  def ensure_system_admin_or_owner
    if current_user.present? && current_user.role != 'owner'
      flash[:danger] = '権限がありません'
      redirect_to users_path
    end
  end

  #owner,動画投稿者のみ許可
  def ensure_user
    if current_system_admin.present?
      flash[:danger] = '権限がありません'
      redirect_to users_path
    end
  end
  
end
