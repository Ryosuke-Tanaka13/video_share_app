class VideosController < ApplicationController
  include CommentReply
  helper_method :account_logged_in?
  before_action :ensure_logged_in, except: :show
  before_action :set_organization, only: %i[index]
  before_action :set_video, only: %i[show edit update destroy]
  before_action :ensure_admin_or_user, only: %i[new create edit update destroy]
  before_action :ensure_user, only: %i[new create]
  before_action :ensure_admin_or_owner_or_correct_user, only: %i[update]
  before_action :ensure_admin, only: %i[destroy]
  before_action :ensure_my_organization, exept: %i[new create]
  before_action :ensure_logged_in_viewer, only: %i[show]
  before_action :ensure_admin_for_access_hidden, only: %i[show edit update]

  def index
    # 動画検索機能用に記載
    @search_params = video_search_params
    if current_system_admin.present?
      # 動画検索機能用に記載 リセットボタン、検索ボタン押下後paramsにorganization_idが含まれないためsessionに保存
      session[:organization_id] = params[:organization_id]
      @organization_videos = Video.includes([:video_blob]).user_has(params[:organization_id])
    elsif current_user.present?
      @organization_videos = Video.includes([:video_blob]).current_user_has(current_user).available
    elsif current_viewer.present?
      @organization_videos = Video.includes([:video_blob]).current_viewer_has(params[:organization_id]).available.select do |video|
        video.accessible_by?(current_viewer)
      end
    end
  end

  def new
    @video = Video.new
    @video.video_folders.build
    @groups = current_user_with_org_and_groups.organization.groups  
  end
  
  def create
    @video = Video.new(video_params)
    @video.identify_organization_and_user(current_user)
    @video.groups = Group.where(id: params[:video][:group]) if params[:video][:group]
    if @video.save
      flash[:success] = '動画を投稿しました。'
      redirect_to @video
    else
      @groups = current_user.organization.groups if current_user.present?
      render :new
    end
  rescue StandardError => e
    logger.error e.message
    @groups = current_user.organization.groups if current_user.present?
    render :new
  end

  def show
    set_account
    @comment = Comment.new
    @reply = Reply.new
    # 新着順で表示
    @comments = @video.comments.includes(:system_admin, :user, :viewer, :replies).order(created_at: :desc)
  end

  def edit; end

  def update
    if @video.update(video_params)
      flash[:success] = '動画情報を更新しました'
      redirect_to video_url
    else
      render 'edit'
    end
  end

  def destroy
    vimeo_video = VimeoMe2::Video.new(ENV['VIMEO_API_TOKEN'], @video.data_url)
    vimeo_video.destroy
    @video.destroy
    flash[:success] = '削除しました'
    redirect_to videos_url(organization_id: @video.organization.id)
  rescue VimeoMe2::RequestFailed
    @video.destroy
    flash[:success] = '削除しました'
    redirect_to videos_url(organization_id: @video.organization.id)
  end

  private

  def video_params
    params.require(:video).permit(:title, :video, :open_period, :range, :login_set, :popup_before_video,
      :popup_after_video, { folder_ids: [] }, :data_url)
  end

  def video_search_params
    params.fetch(:search, {}).permit(:title_like, :open_period_from, :open_period_to, :range, :user_name)
  end

  # 共通メソッド(organization::foldersコントローラにも記載)
  def set_organization
    @organization = Organization.includes(:groups).find(params[:organization_id])
  end

  def ensure_user
    if current_user.nil?
      # 修正 遷移先はorganization::foldersコントローラのものとは異なる
      redirect_to root_url, flash: { danger: '権限がありません' }
    end
  end

  # videosコントローラ独自メソッド
  def set_video
    @video = Video.find(params[:id])
  end

  def ensure_admin_or_owner_or_correct_user
    unless current_system_admin.present? || @video.my_upload?(current_user) || current_user.role == 'owner'
      redirect_to video_url, flash: { danger: '権限がありません。' }
    end
  end

  def ensure_my_organization
    if current_user.present?
      # indexへのアクセス制限とshow, eidt, update, destroyへのアクセス制限
      if (@organization.present? && current_user.organization_id != @organization.id) ||
         (@video.present? && @video.user_no_available?(current_user))
        flash[:danger] = '権限がありません。'
        redirect_to videos_url(organization_id: current_user.organization_id)
      end
    elsif current_viewer.present?
      # indexへのアクセス制限とshowへのアクセス制限
      if (@organization.present? && current_viewer.organization_viewers.where(organization_id: @organization.id).empty?) ||
         (@video.present? && current_viewer.organization_viewers.where(organization_id: @video.organization_id).empty?)
        flash[:danger] = '権限がありません'
        redirect_back(fallback_location: root_url)
      end
    end
  end

  def ensure_logged_in_viewer
    if !logged_in? && @video.login_set != false
      redirect_to new_viewer_session_url, flash: { danger: '視聴者ログインしてください。' }
    end
  end

  def ensure_admin_for_access_hidden
    if current_system_admin.nil? && @video.is_valid == false
      flash[:danger] = 'すでに削除された動画です。'
      redirect_back(fallback_location: root_url)
    end
  end
end
