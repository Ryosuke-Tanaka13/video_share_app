class VideosController < ApplicationController
  before_action :access_right, only: %i[index]
  before_action :ensure_user, only: %i[new create update]
  before_action :set_video, only: %i[show edit update destroy]
  before_action :organization_user, only: %i[show]
  before_action :ensure_owner_or_correct_user, only: %i[update]
  before_action :ensure_system_admin_or_owner, only: %i[destroy]
  
  def index
    # n+1問題対応.includes([:video_blob])
    @organization_videos = Video.includes([:video_blob]).where(organization_id: params[:organization_id])
  end

  def new
    @video = Video.new
  end

  def create
    @video = Video.new(video_params)
    @video.identify_organization_and_user(current_user)
    if @video.save
      # 今後必要に応じてファイル形式変換処理
      # ConvertVideoJob.perform_later(@video.id)
      # snip response boilerplate
      flash[:success] = '動画を投稿しました。'
      # フォルダ一覧ページの最新のpathをまだmergeしていないので、当初のpathをいったん使用
      redirect_to video_path
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @video.owner_has?(current_user) && @video.update(video_params)
      flash[:success] = "動画情報を更新しました"
      redirect_to video_path
    else
      render 'edit'
    end
  end

  def destroy
    if (current_system_admin.present? || @video.owner_has?(current_user)) && @video.destroy
      flash[:danger] = '動画を削除しました'
      redirect_to videos_path(organization_id:@video.organization.id)
    else
      redirect_to videos_path(organization_id:@video.organization.id)
    end
  end

  private

  def video_params
    params.require(:video).permit(:title, :video, :open_period, :range, :comment_public, :login_set, :popup_before_video,
      :popup_after_video)
  end

  def set_video
    @video = Video.find(params[:id])
  end

  def access_right
    @organization = Organization.find(params[:organization_id])
    if (current_user.present? && current_user.organization_id != @organization.id) || (current_user.nil? && current_system_admin.nil?)           
      flash[:danger] = '権限がありません'
      redirect_to root_path
    end
  end
  
  def ensure_user
    if current_user.nil?
      flash[:danger] = '権限がありません'
      redirect_to root_path
    end
  end
  
  # 動画投稿者は、別組織の動画詳細ページを見れない。
  # 視聴者は、現開発段階ではあらゆる動画詳細ページを見れる。(今後、組織との紐付けなどの実装に伴い修正が必要)
  def organization_user
    if current_user.present?
      unless @video.owner_has?(current_user)
        flash[:danger] = "別組織の動画のため表示できません"
        redirect_to videos_path(organization_id: current_user.organization.id)
      end
    end
  end

  def ensure_owner_or_correct_user
    unless @video.my_upload?(current_user) || current_user.role == 'owner' 
      flash[:danger] = '権限がありません'
      redirect_to video_path
    end
  end

  def ensure_system_admin_or_owner
    if current_user.present? && current_user.role != 'owner'
      redirect_to videos_path(organization_id: current_user.organization.id), flash: { danger: '権限がありません' }
    end
  end
end
