class VideosController < ApplicationController
  include CommentReply
  helper_method :account_logged_in?
  before_action :ensure_logged_in, except: :show
  before_action :set_organization, only: %i[index]
  before_action :ensure_admin_or_user, only: %i[edit update]
  before_action :ensure_user, only: %i[new create]
  before_action :ensure_admin_or_owner_or_correct_user, only: %i[update]
  before_action :ensure_admin, only: %i[destroy]
  before_action :ensure_my_organization_videos, only: %i[index]
  before_action :ensure_my_organization_set_video, only: %i[show edit update destroy]
  # 視聴者がログインしている場合、表示されているビデオの視聴グループ＝現在の視聴者の視聴グループでなければ、締め出す下記のメソッド追加予定
  # before_action :limited_viewer, only: %i[show]
  before_action :ensure_logged_in_viewer, only: %i[show]
  before_action :ensure_admin_for_access_hidden, only: %i[show edit update]

  def index
    if current_system_admin
      @organization_videos = Video.user_has(params[:organization_id])
    elsif current_user
      @organization_videos = Video.current_user_has(current_user).available
    elsif current_viewer
      @organization_videos = Video.current_viewer_has(params[:organization_id]).available
      # 現在の視聴者の視聴グループに紐づくビデオのみを表示するよう修正が必要(第２フェーズ)
    end
  end

  def new
    @video = Video.new
    @video.video_folders.build
  end

  def create
    @video = Video.new(video_params)
    @video.identify_organization_and_user(current_user)
    if @video.save
      flash[:success] = '動画を投稿しました。'
      redirect_to @video
    else
      render :new
    end
  end

  def show
    @video = set_video
    # current_viewerの視聴状況が未作成の場合、視聴率が0.0%のインスタンスを生成
    set_current_viewer_video_status
    set_account
    @comment = Comment.new
    @reply = Reply.new
    # 新着順で表示
    @comments = @video.comments.includes(:system_admin, :user, :viewer, :replies).order(created_at: :desc)
  end

  def edit
    @video = set_video
  end

  def update
    @video = set_video
    if @video.update(video_params)
      flash[:success] = '動画情報を更新しました。'
      redirect_to video_url
    else
      render 'edit'
    end
  end

  def destroy
    @video = set_video
    @video.destroy!
    flash[:success] = '削除しました。'
    redirect_to videos_url(organization_id: @video.organization.id)
  end

  private

  def set_video
    Video.find(params[:id])
  end

  def video_params
    params.require(:video).permit(:title, :video, :open_period, :range, :comment_public, :login_set, :popup_before_video,
      :popup_after_video, { folder_ids: [] }, :data_url)
  end

  def set_current_viewer_video_status
    if current_viewer
      video = set_video
      @video_status = current_viewer.video_status_of_the_set_video(video.id)
      unless @video_status.present?
        current_viewer.video_statuses.create!(video_id: video.id, watched_ratio: 0.0)
      end
      @video_status = current_viewer.video_status_of_the_set_video(video.id)
    end
  end

  # before_actionとして記載(organization::foldersコントローラでも定義)
  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def ensure_user
    if current_user.nil?
      # 修正 遷移先はorganization::foldersコントローラのものとは異なる
      redirect_to root_url, flash: { danger: '権限がありません。' }
    end
  end

  # before_actionとして記載(下記はいずれも、videosコントローラでの独自定義)
  def ensure_admin_or_owner_or_correct_user
    video = set_video
    unless current_system_admin || video.my_upload?(current_user) || current_user.owner?
      redirect_to video_url, flash: { danger: '権限がありません。' }
    end
  end

  # 自組織の動画一覧ページのみアクセス可能
  def ensure_my_organization_videos
    if current_user
      if current_user.organization_id != @organization.id
        flash[:danger] = '権限がありません。'
        redirect_to videos_url(organization_id: current_user.organization_id)
      end
    elsif current_viewer
      if current_viewer.ensure_member(@organization.id).empty?
        flash[:danger] = '権限がありません。'
        redirect_back(fallback_location: root_url)
      end
    end
  end

  def ensure_my_organization_set_video
    # userは、自組織のvideoに対してのみshow,edit,update,destroy可能
    video = set_video
    if current_user
      if video.user_no_available?(current_user)
        flash[:danger] = '権限がありません。'
        redirect_to videos_url(organization_id: current_user.organization_id)
      end
    # viewerは、自組織のvideoに対してのみshow可能
    elsif current_viewer
      if current_viewer.ensure_member(video.organization_id).empty?
        flash[:danger] = '権限がありません。'
        redirect_back(fallback_location: root_url)
      end
    end
  end

  def ensure_logged_in_viewer
    video = set_video
    if !logged_in? && video.login_need?
      redirect_to new_viewer_session_url, flash: { danger: '視聴者ログインしてください。' }
    end
  end

  def ensure_admin_for_access_hidden
    video = set_video
    if current_system_admin.nil? && video.not_valid?
      flash[:danger] = 'すでに削除された動画です。'
      redirect_back(fallback_location: root_url)
    end
  end
end
