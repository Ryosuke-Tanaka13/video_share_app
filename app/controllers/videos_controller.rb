class VideosController < ApplicationController
  before_action :ensure_logged_in, except: :show
  before_action :set_organization, only: %i[index]
  before_action :set_video, only: %i[show edit update destroy]
  before_action :ensure_admin_or_user, only: %i[new create edit update destroy]
  before_action :ensure_user, only: %i[new create]
  before_action :ensure_admin_or_owner_or_correct_user, only: %i[update]
  before_action :ensure_admin, only: %i[destroy]
  before_action :ensure_my_organization, exept: %i[new create]
  # 視聴者がログインしている場合、表示されているビデオの視聴グループ＝現在の視聴者の視聴グループでなければ、締め出す下記のメソッド追加予定
  # before_action :limited_viewer, only: %i[show]
  before_action :ensure_logged_in_viewer, only: %i[show]
  before_action :ensure_admin_for_access_hidden, only: %i[show edit update]

  def index
    if current_system_admin.present?
      # n+1問題対応.includes([:video_blob])
      @organization_videos = Video.includes([:video_blob]).user_has(params[:organization_id])
    elsif current_user.present?
      @organization_videos = Video.includes([:video_blob]).current_user_has(current_user).available
      # elsif 視聴者がログインしている場合、現在の視聴者の視聴グループに紐づくビデオのみを表示する条件分岐が今後必要
    end
  end

  def new
    @video = Video.new
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
  # アプリ側ではなく、vimeo側に原因があるエラーのとき(容量不足)
  rescue StandardError
    render :new
  end

  def show; end

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
    @vimeo_video = VimeoMe2::Video.new(ENV['VIMEO_API_TOKEN'], @video.data_url)
    @vimeo_video.destroy
    @video.destroy
    flash[:success] = '削除しました'
    redirect_to videos_url(organization_id: @video.organization.id)
  rescue StandardError
    @video.destroy
    flash[:success] = '削除しました'
    redirect_to videos_url(organization_id: @video.organization.id)
  end

  private

  def video_params
    params.require(:video).permit(:title, :video, :open_period, :range, :comment_public, :login_set, :popup_before_video,
      :popup_after_video, :data_url)
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
    # 真偽判定メソッド加藤さんに合わせる予定
    if current_system_admin.nil? && current_user.nil?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end

  def ensure_admin
    # 真偽判定メソッド加藤さんに合わせる予定
    unless current_system_admin.present?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end

  # 金野さんと共通メソッド appコントローラから継承？
  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def ensure_user
    if current_user.nil?
      redirect_to users_url, flash: { danger: '権限がありません' }
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
      # indexへのアクセス制限
      if @organization.present? && current_user.organization_id != @organization.id
        flash[:danger] = '権限がありません。'
        redirect_to videos_url(organization_id: current_user.organization_id)
      # show, eidt, update, destroyへのアクセス制限
      elsif @video.present? && (@video.organization_id != current_user.organization_id)
        flash[:danger] = '権限がありません。'
        redirect_to videos_url(organization_id: current_user.organization_id)
      end
    end
    # 視聴者がログインしている場合の条件分岐も今後必要
    # indexへのアクセス制限
    # showへのアクセス制限
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
