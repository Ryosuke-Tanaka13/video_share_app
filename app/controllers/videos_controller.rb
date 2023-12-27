class VideosController < ApplicationController
  require 'open3'
  include CommentReply
  helper_method :account_logged_in?
  before_action :ensure_logged_in, except: :show
  before_action :set_organization, only: %i[index]
  before_action :set_video, only: %i[show edit update destroy video_edit]
  before_action :ensure_admin_or_user, only: %i[new create edit update destroy video_edit]
  before_action :ensure_user, only: %i[new create]
  before_action :ensure_admin_or_owner_or_correct_user, only: %i[update]
  before_action :ensure_admin, only: %i[destroy]
  before_action :ensure_my_organization, exept: %i[new create]
  # 視聴者がログインしている場合、表示されているビデオの視聴グループ＝現在の視聴者の視聴グループでなければ、締め出す下記のメソッド追加予定
  # before_action :limited_viewer, only: %i[show]
  before_action :ensure_logged_in_viewer, only: %i[show]
  before_action :ensure_admin_for_access_hidden, only: %i[show edit update]
  before_action :set_vimeo_api_token, only: [:download_vimeo_video]
  

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
      # 動画検索機能用に記載 リセットボタン、検索ボタン押下後paramsにorganization_idが含まれないためsessionに保存
      session[:organization_id] = params[:organization_id]
      @organization_videos = Video.includes([:video_blob]).current_viewer_has(params[:organization_id]).available
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
  # アプリ側ではなく、vimeo側に原因があるエラーのとき(容量不足)
  rescue StandardError
    render :new
  end

  def show
    set_account
    @comment = Comment.new
    @reply = Reply.new
    # 新着順で表示
    @comments = @video.comments.includes(:system_admin, :user, :viewer, :replies).order(created_at: :desc)
  end

  #動画編集ページ#
  def video_edit
    respond_to do |format|
      format.html
      format.js
    end
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

  # --------Vimeoの動画を一時ダウンロードする場所ーーーーーーーーー
  desktop_path = Rails.root.join('public', 'videos')
  # FileUtils.mkdir_p(tmp_dir) unless File.directory?(tmp_dir)
  

  def download_vimeo_video
    user_home_directory = Dir.home
    desktop_path = File.join(user_home_directory, 'Desktop')
    output_path = File.join(desktop_path, 'output_video.mp4')

    video_url =  video_url = 'https://vimeo.com/manage/videos/896179079/download'
    access_token = @vimeo_api_token

    download_command = "curl '#{video_url}' -H 'Authorization: Bearer #{access_token}' -L -o '/Users/'shimatanitakahiro@MacBook-Pro/Desktop/output_video.mp4"
    Open3.popen3(download_command) do |stdin, stdout, stderr, wait_thr|
      exit_status = wait_thr.value
      unless exit_status.success?
        # エラーが発生した場合の処理
        puts "エラーが発生しました: #{stderr.read}"
      end
    end
  end
 # -----------------------------------------------------------
 # --------動画編集ーーーーーーーーー
 def cut_video
  input_path = 'input_video.mp4'
  output_path = 'output_video.mp4'
  start_time = params[:start_time]
  duration = params[:duration]

  # ffmpegコマンドを生成
  command = "ffmpeg -i #{input_path} -ss #{start_time} -t #{duration} -c copy #{output_path}"

  # コマンドを実行
  system(command)

  # ここで保存などの後処理を行う
end

# -----------------------------------------------------------
  private

  def video_params
    params.require(:video).permit(:title, :video, :open_period, :range, :comment_public, :login_set, :popup_before_video,
      :popup_after_video, { folder_ids: [] }, :data_url)
  end

  def video_search_params
    params.fetch(:search, {}).permit(:title_like, :open_period_from, :open_period_to, :range, :user_name)
  end

  # 共通メソッド(organization::foldersコントローラにも記載)
  def set_organization
    @organization = Organization.find(params[:organization_id])
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

  def set_vimeo_api_token
    @vimeo_api_token = ENV['VIMEO_API_TOKEN']
  end
end
