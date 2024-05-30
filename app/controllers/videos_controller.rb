class VideosController < ApplicationController
  include CommentReply 
  helper_method :account_logged_in?
  before_action :ensure_logged_in, except: :show
  before_action :set_organization, only: %i[index]
  before_action :set_video, only: %i[show edit update destroy popup_after]
  before_action :set_user, only: %i[new show index popup_before popup_after]
  before_action :set_viewer, only: %i[popup_before popup_after]
  before_action :ensure_admin_or_user, only: %i[new create edit update destroy]
  before_action :ensure_user, only: %i[new create]
  before_action :ensure_admin_or_owner_or_correct_user, only: %i[update]
  before_action :ensure_admin, only: %i[destroy]
  before_action :ensure_my_organization_videos, only: %i[index]
  before_action :ensure_exist_set_video, only: %i[show edit update]
  before_action :ensure_my_organization_set_video, only: %i[show edit update destroy]
  # 視聴者がログインしている場合、表示されているビデオの視聴グループ＝現在の視聴者の視聴グループでなければ、締め出す下記のメソッド追加予定
  # before_action :limited_viewer, only: %i[show]
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
      # 動画検索機能用に記載 リセットボタン、検索ボタン押下後paramsにorganization_idが含まれないためsessionに保存
      session[:organization_id] = params[:organization_id]
      @organization_videos = Video.includes([:video_blob]).current_viewer_has(params[:organization_id]).available
      # 現在の視聴者の視聴グループに紐づくビデオのみを表示するよう修正が必要(第２フェーズ)
    end
  end

  def new
    @organization = current_user.organization
    @video = Video.new
    @video.video_folders.build
  end

  def create
    @user = current_user
    @video = Video.new(video_params)
    @video.identify_organization_and_user(current_user)
    if @video.save
      if params[:video][:pre_video_questionnaire_id].present?
        @video.update(pre_video_questionnaire_id: params[:video][:pre_video_questionnaire_id])
      end
      if params[:video][:post_video_questionnaire_id].present?
        @video.update(post_video_questionnaire_id: params[:video][:post_video_questionnaire_id])
      end
      flash[:success] = '動画を投稿しました。'
      redirect_to @video
    else
      render :new
    end
  end
  
  def show
    @comment = Comment.new
    @reply = Reply.new
    # 新着順で表示
    @comments = @video.comments.includes(:system_admin, :user, :viewer, :replies).order(created_at: :desc)
  end

  def popup_before
    
    @video = Video.find_by(id_digest: params[:id])
    Rails.logger.debug("Video found: #{@video.inspect}")
    if @video.nil?
      redirect_to root_path, alert: "Video not found"
      return
    end
    @questionnaire = @video.pre_video_questionnaire
    @pre_video_questions = JSON.parse(@questionnaire.pre_video_questionnaire) if @questionnaire&.pre_video_questionnaire.present?
    respond_to do |format|
      format.js
    end
  end
  
  def popup_after
    @video = Video.find_by(id_digest: params[:id])
  
    @questionnaire = @video.post_video_questionnaire
    Rails.logger.debug("Video found: #{@questionnaire.inspect}")
    if @questionnaire.nil?
      redirect_to root_path, alert: "Question not found"
      return
    end
    @post_video_questions = JSON.parse(@questionnaire.post_video_questionnaire) if @questionnaire&.post_video_questionnaire.present?
    respond_to do |format|
      format.js
    end
  end

  def edit
    set_video
  end

  def update
    set_video
    if @video.update(video_params)
      flash[:success] = '動画情報を更新しました。'
      redirect_to video_url
    else
      render 'edit'
    end
  end

  def destroy
    set_video
    @video.destroy!
    flash[:success] = '削除しました。'
    redirect_to videos_url(organization_id: @video.organization.id)
  end

  private

  def set_video
    @video = Video.find_by(id_digest: params[:id])
  end

  def video_params
    params.require(:video).permit(:title, :video, :open_period, :range, :comment_public, :login_set, :popup_before_video, :popup_after_video, :pre_video_questionnaire_id, :post_video_questionnaire_id, folder_ids: [])
  end

  def video_search_params
    params.fetch(:search, {}).permit(:title_like, :open_period_from, :open_period_to, :range, :user_name)
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
    unless current_system_admin || Video.find_by(id_digest: params[:id]).my_upload?(current_user) || current_user.owner?
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

  def ensure_exist_set_video
    if Video.find_by(id_digest: params[:id]).nil?
      flash[:danger] = '動画が存在しません。'
      redirect_back(fallback_location: root_url)
    end
  end

  def ensure_my_organization_set_video
    # userは、自組織のvideoに対してのみshow,edit,update,destroy可能
    if current_user
      if Video.find_by(id_digest: params[:id]).user_no_available?(current_user)
        flash[:danger] = '権限がありません。'
        redirect_to videos_url(organization_id: current_user.organization_id)
      end
    # viewerは、自組織のvideoに対してのみshow可能
    elsif current_viewer
      if current_viewer.ensure_member(Video.find_by(id_digest: params[:id]).organization_id).empty?
        flash[:danger] = '権限がありません。'
        redirect_back(fallback_location: root_url)
      end
    end
  end

  def ensure_logged_in_viewer
    if !logged_in? && Video.find_by(id_digest: params[:id]).login_need?
      redirect_to new_viewer_session_url, flash: { danger: '視聴者ログインしてください。' }
    end
  end

  def ensure_admin_for_access_hidden
    if current_system_admin.nil? && Video.find_by(id_digest: params[:id]).not_valid?
      flash[:danger] = 'すでに削除された動画です。'
      redirect_back(fallback_location: root_url)
    end
  end

  def set_user
    if current_user.present?
      @user = current_user
    end
  end 

  def set_viewer
    if current_viewer.present?
      @viewer = current_viewer 
    end
  end
end
