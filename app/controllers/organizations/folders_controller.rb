class Organizations::FoldersController < ApplicationController
  layout 'folders'

  before_action :set_organization
  before_action :access_right
  before_action :ensure_admin_or_owner, only: %i[destroy]
  before_action :ensure_user, only: %i[create]
  before_action :set_folder, only: %i[show update destroy]

  def index
    @folders = @organization.folders
    if params[:payment] == "success"
      flash[:success] = "プラン選択が完了しました！"
    end    
  end

  def show
    @videos = @folder.videos.available
  end

  def new
    @folder = Folder.new
  end

  def create
    @folder = Folder.new(folder_params)
    if @folder.create(current_user)
      if URI(request.referer.to_s).path == new_video_path
        redirect_to new_video_url, flash: { success: 'フォルダを作成しました！' }
      else
        redirect_to organization_folders_url, flash: { success: 'フォルダを作成しました！' }
      end
    else
      render 'new'
    end
  end

  def update
    if @folder.update(folder_params)
      redirect_to organization_folders_url
    else
      redirect_to organization_folders_url, flash: { danger: 'フォルダ名が空欄、もしくは同じフォルダ名があります。' }
    end
  end

  def destroy
    if @folder.destroy
      redirect_to organization_folders_url, flash: { danger: 'フォルダを削除しました' }
    else
      redirect_to organization_folders_url
    end
  end

  private

  def folder_params
    params.require(:folder).permit(:name)
  end

  def set_folder
    @folder = Folder.find(params[:id])
  end

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  # システム管理者　set_organizationと同組織投稿者　のみ許可
  def access_right
    if (current_system_admin.nil? && current_user.nil?) || (current_user.present? && current_user.organization_id != @organization.id)
      redirect_to root_url, flash: { danger: '権限がありません' }
    end
  end

  # システム管理者　オーナー　のみ許可
  def ensure_admin_or_owner
    if current_user.present? && current_user.role != 'owner'
      redirect_to users_url, flash: { danger: '権限がありません' }
    end
  end

  # 投稿者のみ許可
  def ensure_user
    if current_user.nil?
      redirect_to users_url, flash: { danger: '権限がありません' }
    end
  end
end
