class Videos::VideoFoldersController < VideosController
  before_action :ensure_admin_or_owner_or_correct_user
  before_action :ensure_my_organization
  skip_before_action :ensure_admin
  before_action :set_video
  
  def destroy
    folder = Folder.find(params[:folder_id])
    video = Video.find_by(id_digest: params[:video_id])
    video_folder = folder.video_folders.find_by(video_id: video.id)
    video_folder.destroy
    redirect_to organization_folder_url(folder, organization_id: params[:organization_id]), flash: { danger: '動画をフォルダ内から削除しました' }
  end

  private

  def set_video
    Video.find_by(id_digest: params[:video_id])
  end

  def ensure_admin_or_owner_or_correct_user
    # videosコントローラのメソッドと、メソッド名は同じ、処理内容はオーバーライド
    video = set_video
    unless current_system_admin.present? || video.user_id == current_user.id || current_user.role == 'owner'
      redirect_to organization_folders_url(params[:organization_id]), flash: { danger: '権限がありません。' }
    end
  end

  def ensure_my_organization
    # videosコントローラのメソッドと、メソッド名は同じ、処理内容はオーバーライド
    if current_user.present?
      video = set_video
      unless current_user.organization_id == video.organization_id
        redirect_to organization_folders_url(params[:organization_id]), flash: { danger: '権限がありません。' }
      end
    end
  end
end
