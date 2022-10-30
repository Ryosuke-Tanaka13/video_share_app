class Videos::RecordingsController < ApplicationController
  # before_action :ensure_logged_in, except: :show
  # before_action :set_organization, only: %i[index]
  # before_action :set_video, only: %i[show edit update destroy]
  # before_action :ensure_admin_or_user, only: %i[new create edit update destroy]
  # before_action :ensure_user, only: %i[new create update]
  # before_action :ensure_owner_or_correct_user, only: %i[update]
  # before_action :ensure_system_admin_or_owner, only: %i[destroy]
  # before_action :ensure_my_organization, exept: %i[new create]
  # 視聴者がログインしている場合、表示されているビデオの視聴グループ＝現在の視聴者の視聴グループでなければ、締め出す下記のメソッド追加予定
  # before_action :limited_viewer, only: %i[show]
  # before_action :ensure_logged_in_viewer, only: %i[show]
  layout 'recordings'

  def index
    # n+1問題対応.includes([:video_blob])
    @organization_videos = Video.includes([:video_blob]).where(organization_id: params[:organization_id])
    # 視聴者がログインしている場合、現在の視聴者の視聴グループに紐づくビデオのみを表示する条件分岐が今後必要
  end

  def new
    # @video = Video.new
  end

  def create
    @video = Video.new(video_params)
    @video.identify_organization_and_user(current_user)
    if @video.save
      # 今後必要に応じてファイル形式変換処理
      # ConvertVideoJob.perform_later(@video.id)
      # snip response boilerplate
      flash[:success] = '動画を投稿しました。'
      redirect_to @video
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @video.update(video_params)
      flash[:success] = '動画情報を更新しました'
      redirect_to video_path
    else
      render 'edit'
    end
  end

  def destroy
    @video.destroy
    flash[:danger] = '動画を削除しました'
    redirect_to videos_path(organization_id: @video.organization.id)
  end

  private

  def video_params
    params.require(:video).permit(:title, :video, :open_period, :range, :comment_public, :login_set, :popup_before_video,
      :popup_after_video)
  end

  # 加藤さんと共通メソッド appコントローラから継承？
  def logged_in?
    !current_system_admin.nil? || !current_user.nil? || !current_viewer.nil?
  end

  def ensure_logged_in
    unless logged_in?
      flash[:danger] = 'ログインしてください。'
      redirect_to root_url
    end
  end

  def ensure_admin_or_user
    if current_system_admin.nil? && current_user.nil?
      flash[:danger] = '権限がありません'
      redirect_to root_path
    end
  end

  # 金野さんと共通メソッド appコントローラから継承？
  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def ensure_user
    if current_user.nil?
      flash[:danger] = '権限がありません'
      redirect_to root_path
    end
  end

  def ensure_system_admin_or_owner
    if current_user.present? && current_user.role != 'owner'
      redirect_to videos_path(organization_id: current_user.organization.id), flash: { danger: '権限がありません' }
    end
  end

  # videosコントローラ独自メソッド
  def set_video
    @video = Video.find(params[:id])
  end

  def ensure_owner_or_correct_user
    unless @video.my_upload?(current_user) || current_user.role == 'owner'
      flash[:danger] = '権限がありません'
      redirect_to video_path
    end
  end

  def ensure_my_organization
    if current_user.present?
      # indexへのアクセス制限
      if @organization.present? && current_user.organization_id != @organization.id
        flash[:danger] = '権限がありません'
        redirect_to videos_path(organization_id: current_user.organization.id)
      # show, eidt, update, destroyへのアクセス制限
      elsif @video.present? && (@video.organization_id != current_user.organization_id)
        flash[:danger] = '権限がありません'
        redirect_to videos_path(organization_id: current_user.organization.id)
      end
    end
    # 視聴者がログインしている場合の条件分岐も今後必要
    # indexへのアクセス制限
    # showへのアクセス制限
  end

  def ensure_logged_in_viewer
    if !logged_in? && @video.login_set != false
      flash[:danger] = '視聴者でログインしてください'
      redirect_to new_viewer_session_path
    end
  end
end
