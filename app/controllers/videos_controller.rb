class VideosController < ApplicationController
  before_action :authenticate_user_or_system_admin, only: %i[index]
  before_action :authenticate_user!, only: %i[new create]
  before_action :set_video, only: %i[show edit update destroy]
  # 投稿者本人またはオーナー→edit, update(追加予定)
  before_action :ensure_owner_or_system_admin, only: %i[destroy]

  def index
    if user_signed_in?
      # n+1問題対応.includes([:video_blob])
      @organization_videos = Video.includes([:video_blob]).current_owner_has(current_user)
    elsif system_admin_signed_in?
      @videos = Video.includes([:video_blob]).all
    end
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
      redirect_to videos_url
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update; end

  def destroy
    if user_signed_in?
      if @video.owner_has?(current_user) && @video.destroy
        flash[:danger] = '動画を削除しました'
        redirect_to videos_path
      end
    elsif system_admin_signed_in?
      if @video.destroy
        flash[:danger] = '動画を削除しました'
        redirect_to videos_path
      end
    end
  end

  private

  def video_params
    params.require(:video).permit(:title, :video, :open_period, :range, :comment_public, :login_set, :popup_before_video,
      :popup_after_video)
  end

  def authenticate_user_or_system_admin
    unless user_signed_in? || system_admin_signed_in? 
      redirect_to new_user_session_url
    end
  end

  def set_video
    @video = Video.find(params[:id])
  end

  def ensure_owner_or_system_admin
    if user_signed_in?
      if current_user.role != 'owner' 
        flash[:danger] = '権限がありません'
        redirect_to users_path
      end 
    end
  end
end
